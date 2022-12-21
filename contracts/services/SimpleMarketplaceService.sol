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
    uint256 private _offeringNonces;


    address public _admin; // is a mutil sig address when deploy
    address public _parameterAddr;

    mapping(bytes32 => Marketplace.Offering) public _offeringRegistry;
    bytes32[] public _arrayOffering;


    function initialize(address admin, address parameterControl) initializer public {
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

    function arrayOffering() external view returns (bytes32[] memory) {
        return _arrayOffering;
    }

    // NFTs's owner place offering
    function listToken(address hostContractErc721, uint tokenId, address erc20Token, uint price) external virtual nonReentrant returns (bytes32) {
        // owner nft is sender
        address nftOwner = msg.sender;

        // get hostContract of erc-721
        ERC721Upgradeable hostContract = ERC721Upgradeable(hostContractErc721);
        require(hostContract.ownerOf(tokenId) == nftOwner, Errors.INVALID_ERC721_OWNER);
        // check approval of erc-721 on this contract
        bool approval = hostContract.isApprovedForAll(nftOwner, address(this));
        require(approval == true, Errors.ERC_721_NOT_APPROVED);

        // create offering nonce by counter
        _offeringNonces++;
        // init offering id
        bytes32 offeringId = keccak256(abi.encodePacked(StringsUpgradeable.toString(_offeringNonces), hostContractErc721, StringsUpgradeable.toString(tokenId)));
        // create offering by id
        _offeringRegistry[offeringId].offerer = nftOwner;
        _offeringRegistry[offeringId].hostContract = hostContractErc721;
        _offeringRegistry[offeringId].tokenId = tokenId;
        _offeringRegistry[offeringId].price = price;
        if (erc20Token != address(0x0)) {
            _offeringRegistry[offeringId].erc20Token = erc20Token;
        } else {
            _offeringRegistry[offeringId].erc20Token = address(0x0);
        }
        // transfer erc-721 token from offerer to this contract
        hostContract.transferFrom(nftOwner, address(this), tokenId);

        _arrayOffering.push(offeringId);
        emit Marketplace.ListingToken(offeringId, hostContractErc721, nftOwner, tokenId, price);
        return offeringId;
    }

    function purchaseToken(bytes32 _offeringId) external virtual nonReentrant payable {
        // get offer
        Marketplace.Offering memory _offer = _offeringRegistry[_offeringId];
        address hostContractOffering = _offer.hostContract;
        ERC721Upgradeable hostContract = ERC721Upgradeable(hostContractOffering);
        uint tokenID = _offer.tokenId;
        address offerer = _offer.offerer;
        bool isERC20 = _offer.erc20Token != address(0x0);

        // buyer is sender
        Marketplace.CloseOfferingData memory _closeOfferingData;
        ERC20Upgradeable token;
        if (isERC20) {
            token = ERC20Upgradeable(_offer.erc20Token);
            _closeOfferingData = Marketplace.CloseOfferingData(
                msg.sender,
                _offer.price,
                _offer.price,
                token.balanceOf(msg.sender),
                token.allowance(msg.sender, address(this)),
                _offer.erc20Token
            );
        } else {
            _closeOfferingData = Marketplace.CloseOfferingData(
                msg.sender,
                _offer.price,
                _offer.price,
                0,
                0,
                address(0x0) // is ETH
            );
        }

        // check require
        require(hostContract.ownerOf(tokenID) == offerer, Errors.INVALID_ERC721_OWNER);
        if (isERC20) {
            // check approval of erc-20 on this contract
            require(_closeOfferingData.approvalToken >= _closeOfferingData.price, Errors.ERC20_NOT_APPROVED);
            require(_closeOfferingData.balanceBuyer >= _closeOfferingData.price, Errors.ERC20_BALANCE_INVALID);
        } else {
            require(msg.value >= _closeOfferingData.price, Errors.VALUE_INVALID);
        }
        require(!_offeringRegistry[_offeringId].closed, Errors.OFFERING_CLOSED);

        // transfer erc-721
        hostContract.safeTransferFrom(address(this), _closeOfferingData.buyer, tokenID);

        // logic for 
        // benefit of operator here
        ParameterControl parameterController = ParameterControl(_parameterAddr);
        Marketplace.Benefit memory _benefit = Marketplace.Benefit(0, 0, 0, 0, 0);
        _benefit.benefitPercentOperator = parameterController.getUInt256(MarketplaceServiceConfigs.MARKETPLACE_BENEFIT_PERCENT);
        if (_benefit.benefitPercentOperator == 0) {
            _benefit.benefitPercentOperator = MarketplaceServiceConfigs.DEFAULT_MARKETPLACE_BENEFIT_PERCENT;
        }
        if (_benefit.benefitPercentOperator > 0) {
            _benefit.benefitOperator = _closeOfferingData.originPrice * _benefit.benefitPercentOperator / 10000;
            _closeOfferingData.price -= _benefit.benefitOperator;
        }

        if (isERC20) {
            require(token.transferFrom(_closeOfferingData.buyer, address(this), _closeOfferingData.originPrice), Errors.TRANSFER_FAIL);
            require(token.transferFrom(address(this), _offer.offerer, _closeOfferingData.price), Errors.TRANSFER_FAIL);
        } else {
            require(address(this).balance > 0, Errors.VALUE_INVALID);
            (bool success,) = _offer.offerer.call{value : _closeOfferingData.price}("");
            require(success, Errors.TRANSFER_FAIL);
        }
        // close offering
        _offeringRegistry[_offeringId].closed = true;

        emit Marketplace.PurchaseToken(_offeringId, _closeOfferingData.buyer);
    }

    function cancelListing(bytes32 _offeringId) external {
        require(msg.sender == _offeringRegistry[_offeringId].offerer, Errors.INVALID_ERC721_OWNER);
        _offeringRegistry[_offeringId].closed = true;
        emit Marketplace.CancelListing(_offeringId, _offeringRegistry[_offeringId].offerer);
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
