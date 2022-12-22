pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../governance/ParameterControl.sol";
import "../interfaces/IMarketplaceService.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Marketplace.sol";
import "../libs/configs/MarketplaceServiceConfigs.sol";


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
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
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

    /* @Listing
    */
    function arrayListingId() external view returns (bytes32[] memory) {
        return _arrayListingId;
    }

    function _purchaseToken(bytes32 offerId) internal virtual {
        // get offer
        Marketplace.ListingTokenData memory listing = _listingTokens[offerId];
        address hostContractOffering = listing._collectionContract;
        IERC721Upgradeable hostContract = IERC721Upgradeable(hostContractOffering);
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
        require(hostContract.ownerOf(listing._tokenId) == listing._seller, Errors.INVALID_ERC721_OWNER);
        if (isERC20) {
            // check approval of erc-20 on this contract
            require(_closeOfferingData._approvalToken >= _closeOfferingData._price, Errors.ERC20_NOT_APPROVED);
            require(_closeOfferingData._balanceBuyer >= _closeOfferingData._price, Errors.ERC20_BALANCE_INVALID);
        } else {
            require(msg.value >= _closeOfferingData._price, Errors.VALUE_INVALID);
        }
        require(!_listingTokens[offerId]._closed, Errors.OFFERING_CLOSED);

        // transfer erc-721
        hostContract.safeTransferFrom(address(this), _closeOfferingData._buyer, listing._tokenId);

        // logic for 
        // benefit of operator here
        IParameterControl parameterController = IParameterControl(_parameterAddr);
        Marketplace.Benefit memory _benefit = Marketplace.Benefit(0, 0, 0, 0);
        _benefit.benefitPercentOperator = parameterController.getUInt256(MarketplaceServiceConfigs.MARKETPLACE_BENEFIT_PERCENT);
        if (_benefit.benefitPercentOperator == 0) {
            _benefit.benefitPercentOperator = MarketplaceServiceConfigs.DEFAULT_MARKETPLACE_BENEFIT_PERCENT;
        }
        if (_benefit.benefitPercentOperator > 0) {
            _benefit.benefitOperator = _closeOfferingData._originPrice * _benefit.benefitPercentOperator / 10000;
            _closeOfferingData._price -= _benefit.benefitOperator;
        }

        if (isERC20) {
            require(erc20.transferFrom(_closeOfferingData._buyer, address(this), _closeOfferingData._originPrice), Errors.TRANSFER_FAIL);
            require(erc20.transferFrom(address(this), listing._seller, _closeOfferingData._price), Errors.TRANSFER_FAIL);
        } else {
            require(address(this).balance > 0, Errors.VALUE_INVALID);
            (bool success,) = listing._seller.call{value : _closeOfferingData._price}("");
            require(success, Errors.TRANSFER_FAIL);
        }
        // close offering
        _listingTokens[offerId]._closed = true;

        emit Marketplace.PurchaseToken(offerId, listing);
    }

    function _listToken(Marketplace.ListingTokenData memory listingData) internal virtual returns (bytes32) {
        // get hostContract of erc-721
        IERC721Upgradeable hostContract = IERC721Upgradeable(listingData._collectionContract);
        require(hostContract.ownerOf(listingData._tokenId) == msg.sender, Errors.INVALID_ERC721_OWNER);
        // check approval of erc-721 on this contract
        bool approval = hostContract.isApprovedForAll(msg.sender, address(this));
        require(approval == true, Errors.ERC_721_NOT_APPROVED);

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
    function arrayMakeOfferId() external view returns (bytes32[] memory) {
        return _arrayMakeOfferId;
    }

    function _makeOffer(Marketplace.MakeOfferData memory data) internal virtual returns (bytes32) {
        require(data._erc20Token != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(data._collectionContract != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(data._price > 0);
        require(data._durationTime > 0);

        IERC20Upgradeable erc20 = IERC20Upgradeable(data._erc20Token);
        require(erc20.allowance(msg.sender, address(this)) >= data._price);
        // create offering nonce by counter
        _counting++;
        // init offering id
        bytes32 offeringId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_counting), data._collectionContract, StringsUpgradeable.toString(data._tokenId)));
        // create offering by id
        _makeOfferTokens[offeringId] = data;
        _makeOfferTokens[offeringId]._buyer = msg.sender;

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
        Marketplace.MakeOfferData memory offer = _makeOfferTokens[offerId];
        require(!offer._closed);
        IERC721Upgradeable hostContract = IERC721Upgradeable(offer._collectionContract);
        require(hostContract.ownerOf(offer._tokenId) == msg.sender);
        require(hostContract.isApprovedForAll(msg.sender, address(this)));

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
        Marketplace.Benefit memory _benefit = Marketplace.Benefit(0, 0, 0, 0);
        _benefit.benefitPercentOperator = parameterController.getUInt256(MarketplaceServiceConfigs.MARKETPLACE_BENEFIT_PERCENT);
        if (_benefit.benefitPercentOperator == 0) {
            _benefit.benefitPercentOperator = MarketplaceServiceConfigs.DEFAULT_MARKETPLACE_BENEFIT_PERCENT;
        }
        if (_benefit.benefitPercentOperator > 0) {
            _benefit.benefitOperator = closeData._originPrice * _benefit.benefitPercentOperator / 10000;
            closeData._price -= _benefit.benefitOperator;
        }

        // transfer erc-20
        require(erc20.transferFrom(closeData._buyer, address(this), closeData._originPrice), Errors.TRANSFER_FAIL);
        require(erc20.transferFrom(address(this), msg.sender, closeData._price), Errors.TRANSFER_FAIL);

        // transfer erc-721
        hostContract.safeTransferFrom(address(this), closeData._buyer, offer._tokenId);
        _makeOfferTokens[offerId]._closed = true;
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
