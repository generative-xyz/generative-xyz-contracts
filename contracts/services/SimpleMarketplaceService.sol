pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "../governance/ParameterControl.sol";
import "../interfaces/IMarketplaceService.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Marketplace.sol";
import "../libs/configs/MarketplaceServiceConfigs.sol";
import "../interfaces/IRoyaltyFinanceSecondSale.sol";


contract SimpleMarketplaceService is Initializable, ReentrancyGuardUpgradeable, IMarketplaceService {
    uint256 private _counting;

    address public _admin; // is a mutil sig address when deploy
    address public _parameterAddr;

    mapping(bytes32 => Marketplace.ListingTokenData) public _listingTokens;
    bytes32[] public _arrayListingId;

    mapping(bytes32 => Marketplace.MakeOfferData) public _makeOfferTokens;
    bytes32[] public _arrayMakeOfferId;


    function initialize(address admin, address parameterControl) initializer virtual public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(parameterControl != Errors.ZERO_ADDR, Errors.INV_ADD);

        _admin = admin;
        _parameterAddr = parameterControl;
        __ReentrancyGuard_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParamAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_parameterAddr != newAddr) {
            _parameterAddr = newAddr;
        }
    }

    function withdraw(address receiver, address erc20Addr, uint256 amount) external virtual nonReentrant {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        bool success;
        if (erc20Addr == address(0x0)) {
            require(address(this).balance >= amount);
            (success,) = receiver.call{value : amount}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(receiver, amount));
        }
    }

    /* @Royalty: process royalty second sale in case RoyaltyFinanceSecondSale
    */
    function setRoyaltySecondSale(address royaltyReceiver, uint256 tokenId, address erc20Addr, uint256 amount) internal {
        IRoyaltyFinanceSecondSale royaltyFinance = IRoyaltyFinanceSecondSale(royaltyReceiver);
        if (royaltyFinance.supportsInterface(type(IRoyaltyFinanceSecondSale).interfaceId)) {
            royaltyFinance.setRoyaltySecondSale(tokenId, erc20Addr, amount);
        }
    }


    /* @Listing
    */
    function _purchaseToken(bytes32 offerId) internal virtual {
        // close offering
        _listingTokens[offerId]._closed = true;

        // get offer
        Marketplace.ListingTokenData memory listing = _listingTokens[offerId];
        require(!listing._closed || block.timestamp < listing._durationTime, Errors.OFFERING_CLOSED);
        IERC721Upgradeable erc721 = IERC721Upgradeable(listing._collectionContract);
        bool isERC20 = listing._erc20Token != address(0x0);

        Marketplace.CloseData memory _closeOfferingData;
        IERC20Upgradeable erc20;
        if (isERC20) {
            erc20 = IERC20Upgradeable(listing._erc20Token);
            _closeOfferingData = Marketplace.CloseData(
                msg.sender,
                listing._seller,
                listing._price,
                listing._price,
                erc20.balanceOf(msg.sender),
                erc20.allowance(msg.sender, address(this)),
                listing._erc20Token
            );
        } else {
            _closeOfferingData = Marketplace.CloseData(
                msg.sender,
                listing._seller,
                listing._price,
                listing._price,
                0,
                0,
                address(0x0) // is ETH
            );
        }

        // check require
        require(erc721.ownerOf(listing._tokenId) == listing._seller, Errors.INVALID_ERC721_OWNER);
        if (isERC20) {
            // check approval of erc-20 on this contract
            require(_closeOfferingData._approvalToken >= _closeOfferingData._price, Errors.ERC20_NOT_APPROVED);
            require(_closeOfferingData._balanceBuyer >= _closeOfferingData._price, Errors.ERC20_BALANCE_INVALID);
        } else {
            require(msg.value >= _closeOfferingData._price, Errors.VALUE_INVALID);
        }
        require(!_listingTokens[offerId]._closed, Errors.OFFERING_CLOSED);

        // transfer erc-721
        erc721.safeTransferFrom(_closeOfferingData._seller, _closeOfferingData._buyer, listing._tokenId);

        // logic for 
        // benefit of operator here
        IParameterControl parameterController = IParameterControl(_parameterAddr);
        Marketplace.Benefit memory _benefit = Marketplace.Benefit(Errors.ZERO_ADDR, 0, 0, 0);
        _benefit._benefitPercentOperator = parameterController.getUInt256(MarketplaceServiceConfigs.MARKETPLACE_BENEFIT_PERCENT);
        if (_benefit._benefitPercentOperator == 0) {
            _benefit._benefitPercentOperator = MarketplaceServiceConfigs.DEFAULT_MARKETPLACE_BENEFIT_PERCENT;
        }
        if (_benefit._benefitPercentOperator > 0) {
            _benefit._benefitOperator = _closeOfferingData._originPrice * _benefit._benefitPercentOperator / 10000;
            _closeOfferingData._price -= _benefit._benefitOperator;
        }

        if (erc721.supportsInterface(type(IERC2981).interfaceId)) {
            IERC2981 erc2981 = IERC2981(listing._collectionContract);
            (address _receiver, uint256 _royaltyAmount) = erc2981.royaltyInfo(listing._tokenId, _closeOfferingData._originPrice);
            _benefit._royalty = _royaltyAmount;
            _benefit._royaltyReceiver = _receiver;
            _closeOfferingData._price -= _benefit._royalty;
        }

        if (isERC20) {
            require(erc20.transferFrom(_closeOfferingData._buyer, address(this), _closeOfferingData._originPrice), Errors.TRANSFER_FAIL);
            require(erc20.transfer(listing._seller, _closeOfferingData._price), Errors.TRANSFER_FAIL);

            // pay royalty second sale
            if (_benefit._royaltyReceiver != Errors.ZERO_ADDR && _benefit._royalty > 0) {
                require(erc20.transfer(_benefit._royaltyReceiver, _benefit._royalty), Errors.TRANSFER_FAIL);
                setRoyaltySecondSale(_benefit._royaltyReceiver, listing._tokenId, listing._erc20Token, _benefit._royalty);
            }
        } else {
            require(address(this).balance > 0, Errors.VALUE_INVALID);
            bool success;
            (success,) = listing._seller.call{value : _closeOfferingData._price}("");
            require(success, Errors.TRANSFER_FAIL);

            // pay royalty second sale
            if (_benefit._royaltyReceiver != Errors.ZERO_ADDR && _benefit._royalty > 0) {
                (success,) = _benefit._royaltyReceiver.call{value : _benefit._royalty}("");
                require(success, Errors.TRANSFER_FAIL);
                setRoyaltySecondSale(_benefit._royaltyReceiver, listing._tokenId, listing._erc20Token, _benefit._royalty);
            }
        }

        emit Marketplace.PurchaseToken(offerId, listing);
    }

    function _listToken(Marketplace.ListingTokenData memory listingData) internal virtual returns (bytes32) {
        // get hostContract of erc-721
        IERC721Upgradeable erc721 = IERC721Upgradeable(listingData._collectionContract);
        require(erc721.ownerOf(listingData._tokenId) == msg.sender, Errors.INVALID_ERC721_OWNER);
        require(listingData._price > 0, Errors.ZERO_PRICE);
        require(listingData._durationTime > 0, Errors.ZERO_DURATION);
        // check approval of erc-721 on this contract
        require(erc721.isApprovedForAll(msg.sender, address(this)) == true, Errors.ERC_721_NOT_APPROVED);

        // create offering nonce by counter
        _counting++;
        // init offering id
        bytes32 offeringId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_counting), listingData._collectionContract, StringsUpgradeable.toString(listingData._tokenId)));
        // create offering by id
        _listingTokens[offeringId] = listingData;
        _listingTokens[offeringId]._seller = msg.sender;

        _arrayListingId.push(offeringId);
        emit Marketplace.ListingToken(offeringId, listingData);
        return offeringId;
    }

    function _cancelListing(bytes32 _offeringId) internal virtual {
        require(msg.sender == _listingTokens[_offeringId]._seller, Errors.INVALID_ERC721_OWNER);
        require(!_listingTokens[_offeringId]._closed);
        _listingTokens[_offeringId]._closed = true;
        emit Marketplace.CancelListing(_offeringId, _listingTokens[_offeringId]);
    }

    function listToken(Marketplace.ListingTokenData memory listingData) external virtual nonReentrant returns (bytes32) {
        return _listToken(listingData);
    }

    function purchaseToken(bytes32 offeringId) external virtual nonReentrant payable {
        _purchaseToken(offeringId);
    }

    function cancelListing(bytes32 _offeringId) external virtual {
        _cancelListing(_offeringId);
    }

    /* @MakeOffer 
    */
    function _makeOffer(Marketplace.MakeOfferData memory data) internal virtual returns (bytes32) {
        require(data._erc20Token != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(data._collectionContract != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(data._price > 0, Errors.ZERO_PRICE);
        require(data._durationTime > 0, Errors.ZERO_DURATION);

        IERC20Upgradeable erc20 = IERC20Upgradeable(data._erc20Token);
        require(erc20.allowance(msg.sender, address(this)) >= data._price);
        // create offering nonce by counter
        _counting++;
        // init offering id
        bytes32 offeringId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_counting), data._collectionContract, StringsUpgradeable.toString(data._tokenId)));
        // create offering by id
        _makeOfferTokens[offeringId] = data;
        _makeOfferTokens[offeringId]._buyer = msg.sender;

        _arrayMakeOfferId.push(offeringId);
        emit Marketplace.MakeOffer(offeringId, data);

        return offeringId;
    }

    function _cancelMakeOffer(bytes32 offerId) internal virtual {
        require(msg.sender == _makeOfferTokens[offerId]._buyer, Errors.INV_ADD);
        require(!_makeOfferTokens[offerId]._closed);
        _makeOfferTokens[offerId]._closed = true;
        emit Marketplace.CancelMakeOffer(offerId, _makeOfferTokens[offerId]);
    }

    function _acceptMakeOffer(bytes32 offerId) internal virtual {
        // close make offer
        _makeOfferTokens[offerId]._closed = true;

        Marketplace.MakeOfferData memory offer = _makeOfferTokens[offerId];
        require(!offer._closed || block.timestamp < offer._durationTime, Errors.OFFERING_CLOSED);
        IERC721Upgradeable erc721 = IERC721Upgradeable(offer._collectionContract);
        require(erc721.ownerOf(offer._tokenId) == msg.sender, Errors.INVALID_ERC721_OWNER);
        require(erc721.isApprovedForAll(msg.sender, address(this)), Errors.ERC_721_NOT_APPROVED);

        IERC20Upgradeable erc20 = IERC20Upgradeable(offer._erc20Token);
        require(erc20.allowance(offer._buyer, address(this)) >= offer._price);

        Marketplace.CloseData memory closeData = Marketplace.CloseData(
            offer._buyer,
            msg.sender,
            offer._price,
            offer._price,
            erc20.balanceOf(offer._buyer),
            erc20.allowance(offer._buyer, address(this)),
            offer._erc20Token
        );

        // logic for 
        // benefit of operator here
        IParameterControl parameterController = IParameterControl(_parameterAddr);
        Marketplace.Benefit memory _benefit = Marketplace.Benefit(Errors.ZERO_ADDR, 0, 0, 0);
        _benefit._benefitPercentOperator = parameterController.getUInt256(MarketplaceServiceConfigs.MARKETPLACE_BENEFIT_PERCENT);
        if (_benefit._benefitPercentOperator == 0) {
            _benefit._benefitPercentOperator = MarketplaceServiceConfigs.DEFAULT_MARKETPLACE_BENEFIT_PERCENT;
        }
        if (_benefit._benefitPercentOperator > 0) {
            _benefit._benefitOperator = closeData._originPrice * _benefit._benefitPercentOperator / 10000;
            closeData._price -= _benefit._benefitOperator;
        }

        if (erc721.supportsInterface(type(IERC2981).interfaceId)) {
            IERC2981 erc2981 = IERC2981(offer._collectionContract);
            (address _receiver, uint256 _royaltyAmount) = erc2981.royaltyInfo(offer._tokenId, closeData._originPrice);
            _benefit._royalty = _royaltyAmount;
            _benefit._royaltyReceiver = _receiver;
            closeData._price -= _benefit._royalty;
        }

        // transfer erc-20
        require(erc20.transferFrom(closeData._buyer, address(this), closeData._originPrice), Errors.TRANSFER_FAIL);
        require(erc20.transfer(closeData._seller, closeData._price), Errors.TRANSFER_FAIL);

        // pay royalty second sale
        if (_benefit._royaltyReceiver != Errors.ZERO_ADDR && _benefit._royalty > 0) {
            require(erc20.transfer(_benefit._royaltyReceiver, _benefit._royalty), Errors.TRANSFER_FAIL);
            setRoyaltySecondSale(_benefit._royaltyReceiver, offer._tokenId, offer._erc20Token, _benefit._royalty);
        }

        // transfer erc-721
        erc721.safeTransferFrom(closeData._seller, closeData._buyer, offer._tokenId);

        emit Marketplace.AcceptMakeOffer(offerId, offer);
    }

    function makeOffer(Marketplace.MakeOfferData memory data) external virtual nonReentrant returns (bytes32) {
        return _makeOffer(data);
    }

    function cancelMakeOffer(bytes32 offerId) external virtual {
        _cancelMakeOffer(offerId);
    }

    function acceptMakeOffer(bytes32 offerId) external virtual nonReentrant {
        _acceptMakeOffer(offerId);
    }
}
