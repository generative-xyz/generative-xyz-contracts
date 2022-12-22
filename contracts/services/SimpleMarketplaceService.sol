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
    uint256 private _listingTokenNonces;


    address public _admin; // is a mutil sig address when deploy
    address public _parameterAddr;

    mapping(bytes32 => Marketplace.ListingTokenData) public _listingTokens;
    bytes32[] public _arrayListingId;


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

    function arrayListingId() external view returns (bytes32[] memory) {
        return _arrayListingId;
    }


    function _purchaseToken(bytes32 offeringId, address buyer) internal virtual {
        // get offer
        Marketplace.ListingTokenData memory _offer = _listingTokens[offeringId];
        address hostContractOffering = _offer._collectionContract;
        IERC721Upgradeable hostContract = IERC721Upgradeable(hostContractOffering);
        uint tokenID = _offer._tokenId;
        address offerer = _offer._seller;
        bool isERC20 = _offer._erc20Token != address(0x0);

        Marketplace.PurchaseTokenData memory _closeOfferingData;
        IERC20Upgradeable erc20;
        if (isERC20) {
            erc20 = IERC20Upgradeable(_offer._erc20Token);
            _closeOfferingData = Marketplace.PurchaseTokenData(
                buyer,
                _offer._price,
                _offer._price,
                erc20.balanceOf(buyer),
                erc20.allowance(buyer, address(this)),
                _offer._erc20Token
            );
        } else {
            _closeOfferingData = Marketplace.PurchaseTokenData(
                buyer,
                _offer._price,
                _offer._price,
                0,
                0,
                address(0x0) // is ETH
            );
        }

        // check require
        require(hostContract.ownerOf(tokenID) == offerer, Errors.INVALID_ERC721_OWNER);
        if (isERC20) {
            // check approval of erc-20 on this contract
            require(_closeOfferingData._approvalToken >= _closeOfferingData._price, Errors.ERC20_NOT_APPROVED);
            require(_closeOfferingData._balanceBuyer >= _closeOfferingData._price, Errors.ERC20_BALANCE_INVALID);
        } else {
            require(msg.value >= _closeOfferingData._price, Errors.VALUE_INVALID);
        }
        require(!_listingTokens[offeringId]._closed, Errors.OFFERING_CLOSED);

        // transfer erc-721
        hostContract.safeTransferFrom(address(this), _closeOfferingData._buyer, tokenID);

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
            require(erc20.transferFrom(address(this), _offer._seller, _closeOfferingData._price), Errors.TRANSFER_FAIL);
        } else {
            require(address(this).balance > 0, Errors.VALUE_INVALID);
            (bool success,) = _offer._seller.call{value : _closeOfferingData._price}("");
            require(success, Errors.TRANSFER_FAIL);
        }
        // close offering
        _listingTokens[offeringId]._closed = true;

        emit Marketplace.PurchaseToken(offeringId, _closeOfferingData._buyer);
    }

    function _listToken(Marketplace.ListingTokenData memory listingData) internal virtual nonReentrant returns (bytes32) {
        // get hostContract of erc-721
        IERC721Upgradeable hostContract = IERC721Upgradeable(listingData._collectionContract);
        require(hostContract.ownerOf(listingData._tokenId) == msg.sender, Errors.INVALID_ERC721_OWNER);
        // check approval of erc-721 on this contract
        bool approval = hostContract.isApprovedForAll(msg.sender, address(this));
        require(approval == true, Errors.ERC_721_NOT_APPROVED);

        // create offering nonce by counter
        _listingTokenNonces++;
        // init offering id
        bytes32 offeringId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_listingTokenNonces), listingData._collectionContract, StringsUpgradeable.toString(listingData._tokenId)));
        // create offering by id
        _listingTokens[offeringId]._seller = msg.sender;
        _listingTokens[offeringId]._collectionContract = listingData._collectionContract;
        _listingTokens[offeringId]._tokenId = listingData._tokenId;
        _listingTokens[offeringId]._price = listingData._price;
        _listingTokens[offeringId]._durationTime = listingData._durationTime;
        _listingTokens[offeringId]._erc20Token = listingData._erc20Token;
        // transfer erc-721 token from offerer to this contract
        //        hostContract.transferFrom(nftOwner, address(this), tokenId);

        _arrayListingId.push(offeringId);
        emit Marketplace.ListingToken(offeringId, listingData._collectionContract, msg.sender, listingData._tokenId, listingData._price);
        return offeringId;
    }

    function _cancelListing(bytes32 _offeringId) internal virtual {
        require(msg.sender == _listingTokens[_offeringId]._seller, Errors.INVALID_ERC721_OWNER);
        require(!_listingTokens[_offeringId]._closed);
        IERC721Upgradeable hostContract = IERC721Upgradeable(_listingTokens[_offeringId]._collectionContract);
        hostContract.safeTransferFrom(address(this), msg.sender, _listingTokens[_offeringId]._tokenId);
        _listingTokens[_offeringId]._closed = true;
        emit Marketplace.CancelListing(_offeringId, _listingTokens[_offeringId]._seller);
    }

    function listToken(Marketplace.ListingTokenData memory listingData) external virtual nonReentrant returns (bytes32) {
        return _listToken(listingData);
    }

    function purchaseToken(bytes32 offeringId) external virtual nonReentrant payable {
        _purchaseToken(offeringId, msg.sender);
    }

    function cancelListing(bytes32 _offeringId) external virtual {
        _cancelListing(_offeringId);
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
}
