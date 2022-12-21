pragma solidity ^0.8.0;

import "./SimpleMarketplaceService.sol";

contract AdvanceMarketplaceService is SimpleMarketplaceService {

    // erc721 -> tokenId
    mapping(address => mapping(uint256 => Marketplace.MultiBuyOffering)) public _multiBuyOffering;

    function initialize(address admin, address parameterControl) initializer override public {
        super.initialize(admin, parameterControl);
    }

    function makeMultiBuyOffering(Marketplace.MultiBuyOffering memory offer, address erc721, uint256 tokenId) external nonReentrant payable {
        _multiBuyOffering[erc721][tokenId] = offer;
        if (offer._erc20Token == Errors.ZERO_ADDR) {
            _multiBuyOffering[erc721][tokenId]._budget = msg.value;
        } else {
            IERC20Upgradeable erc20 = IERC20Upgradeable(offer._erc20Token);
            require(erc20.allowance(msg.sender, address(this)) >= _multiBuyOffering[erc721][tokenId]._budget, Errors.ERC20_NOT_APPROVED);
            require(erc20.transferFrom(msg.sender, address(this), _multiBuyOffering[erc721][tokenId]._budget), Errors.TRANSFER_FAIL);
        }
    }

    function cancelMultiBuyOffering(address erc721, uint256 tokenId) external nonReentrant {
        require(_multiBuyOffering[erc721][tokenId]._buyer == msg.sender);
        if (_multiBuyOffering[erc721][tokenId]._budget > 0) {
            if (_multiBuyOffering[erc721][tokenId]._erc20Token == Errors.ZERO_ADDR) {
                (bool success,) = _multiBuyOffering[erc721][tokenId]._buyer.call{value : _multiBuyOffering[erc721][tokenId]._budget}("");
                require(success);
            } else {
                IERC20Upgradeable erc20 = IERC20Upgradeable(_multiBuyOffering[erc721][tokenId]._erc20Token);
                require(erc20.transferFrom(address(this), _multiBuyOffering[erc721][tokenId]._buyer, _multiBuyOffering[erc721][tokenId]._budget), Errors.TRANSFER_FAIL);
            }
        }
    }

    function listToken(address hostContractErc721, uint tokenId, address erc20Token, uint price) external override nonReentrant returns (bytes32) {
        bytes32 id = _listToken(hostContractErc721, tokenId, erc20Token, price);
        // check multi buy offering
        if (_multiBuyOffering[hostContractErc721][tokenId]._buyer != Errors.ZERO_ADDR) {
            if (_multiBuyOffering[hostContractErc721][tokenId]._erc20Token == _offeringRegistry[id].erc20Token) {
                if (_multiBuyOffering[hostContractErc721][tokenId]._budget > _offeringRegistry[id].price) {
                    _purchaseToken(id, address(this));
                    // transfer erc721 to buyer
                    IERC721Upgradeable hostContract = IERC721Upgradeable(_offeringRegistry[id].hostContract);
                    hostContract.safeTransferFrom(address(this), _multiBuyOffering[hostContractErc721][tokenId]._buyer, tokenId);
                    // calculate budget
                    _multiBuyOffering[hostContractErc721][tokenId]._budget -= _offeringRegistry[id].price;
                }
            }
        }
        return id;
    }
}
