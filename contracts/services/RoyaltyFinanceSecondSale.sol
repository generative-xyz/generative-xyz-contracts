pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IRoyaltyFinanceSecondSale.sol";
import "../interfaces/IParameterControl.sol";

import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/configs/RoyaltyFinanceSecondSaleConfigs.sol";
import "../libs/helpers/Errors.sol";

/*
 this contract will contain royalty second sale of generative nft
 this contract address should be set into GenerativeNFTConfigs.ROYALTY_FIN_ADDRESS
 _admin or _proxyRoyaltySecondSale can call setRoyaltySecondSale to identify how much of royalty second sale for project's owner can withdraw
*/
contract RoyaltyFinanceSecondSale is OwnableUpgradeable, ReentrancyGuardUpgradeable, IRoyaltyFinanceSecondSale {
    // super admin
    address public _admin;
    // parameter control address
    address public _paramsAddress;
    address public _generativeProjectAddr;
    address public _proxyRoyaltySecondSale;

    mapping(address => uint256) public _royaltySecondSaleAdmin;
    mapping(uint256 => mapping(address => mapping(address => uint256))) public _royaltySecondSale;

    function initialize(address admin, address paramAddr, address projectAddr, address proxy) initializer public {
        _admin = admin;
        _paramsAddress = paramAddr;
        _generativeProjectAddr = projectAddr;
        _proxyRoyaltySecondSale = proxy;
        __Ownable_init();
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
        if (_paramsAddress != newAddr) {
            _paramsAddress = newAddr;
        }
    }

    function changeProjectAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change Generative project address
        if (_generativeProjectAddr != newAddr) {
            _generativeProjectAddr = newAddr;
        }
    }

    function changeProxyRoyaltySecondSale(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_proxyRoyaltySecondSale != newAddr) {
            _proxyRoyaltySecondSale = newAddr;
        }
    }

    function withdrawRoyalty(uint256 projectId, address erc20Addr) external {
        require(_royaltySecondSale[projectId][msg.sender][erc20Addr] > 0);
        bool success;
        if (erc20Addr == address(0x0)) {
            (success,) = msg.sender.call{value : _royaltySecondSale[projectId][msg.sender][erc20Addr]}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(msg.sender, _royaltySecondSale[projectId][msg.sender][erc20Addr]));
        }
    }

    function withdraw(address erc20Addr) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        bool success;
        if (erc20Addr == address(0x0)) {
            (success,) = msg.sender.call{value : _royaltySecondSaleAdmin[erc20Addr]}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(msg.sender, _royaltySecondSaleAdmin[erc20Addr]));
        }
    }

    function setRoyaltySecondSale(uint256 tokenId, address erc20Addr, uint256 amount) external payable nonReentrant {
        if (erc20Addr == Errors.ZERO_ADDR) {
            require(msg.value == amount);
        }
        require(_admin == msg.sender || msg.sender == _proxyRoyaltySecondSale, Errors.ONLY_ADMIN_ALLOWED);

        // get project id from tokenId
        uint256 projectId = tokenId / GenerativeNFTConfigs.PROJECT_PADDING;
        IGenerativeProject project = IGenerativeProject(_generativeProjectAddr);
        // get current owner of project
        address receiver = project.ownerOf(projectId);
        require(receiver != Errors.ZERO_ADDR);

        // 90% for owner of project
        uint256 ownerRoyaltySecondSale = RoyaltyFinanceSecondSaleConfigs.DEFAULT_OWNER_ROYALTY_SECOND_SALE;
        if (_paramsAddress != Errors.ZERO_ADDR) {
            IParameterControl _p = IParameterControl(_paramsAddress);
            uint256 r = _p.getUInt256(RoyaltyFinanceSecondSaleConfigs.OWNER_ROYALTY_SECOND_SALE);
            if (r > 0) {
                ownerRoyaltySecondSale = r;
            }
        }
        // set for project's owner
        _royaltySecondSale[projectId][receiver][erc20Addr] += ownerRoyaltySecondSale * amount / 10000;
        // set for _admin
        _royaltySecondSaleAdmin[erc20Addr] = amount - (ownerRoyaltySecondSale * amount / 10000);
    }
}

