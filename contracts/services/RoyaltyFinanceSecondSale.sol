pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";

import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IRoyaltyFinanceSecondSale.sol";
import "../interfaces/IParameterControl.sol";

import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/configs/RoyaltyFinanceSecondSaleConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";

/*
 this contract will contain royalty second sale address of generative nft
 this contract address should be set into GenerativeNFTConfigs.ROYALTY_FIN_ADDRESS
 _admin or _proxyRoyaltySecondSale can call setRoyaltySecondSale to identify how much of royalty second sale for project's owner can withdraw
*/
contract RoyaltyFinanceSecondSale is OwnableUpgradeable, ReentrancyGuardUpgradeable, IRoyaltyFinanceSecondSale, ERC165Upgradeable {
    // super admin
    address public _admin;
    // parameter control address
    address public _paramsAddress;
    address public _generativeProjectAddr;
    mapping(address => bool) public _proxyRoyaltySecondSales;

    // payment info
    mapping(address => uint256) public _royaltySecondSaleAdmin;
    mapping(uint256 => mapping(address => mapping(address => uint256))) public _royaltySecondSale;

    // withdraw info
    mapping(address => uint256) public _royaltySecondSaleAdminWithdrawn;
    mapping(uint256 => mapping(address => mapping(address => uint256))) public _royaltySecondSaleWithdrawn;

    function initialize(address admin, address paramAddr, address projectAddr, address proxy) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(projectAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramsAddress = paramAddr;
        _generativeProjectAddr = projectAddr;
        if (proxy != Errors.ZERO_ADDR) {
            _proxyRoyaltySecondSales[proxy] = true;
        }
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC165_init();
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

    function setProxyRoyaltySecondSale(address addr, bool approve) external {
        require(msg.sender == _admin && addr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // set approve
        _proxyRoyaltySecondSales[addr] = approve;
        emit Royalty.SetProxyRoyaltySecondSale(addr, approve);
    }

    /* @Withdraw payment splitting
    */

    /*
        trigger withdraw to `account`
    */
    function withdrawRoyalty(address account, uint256 projectId, address erc20Addr) external {
        require(_royaltySecondSale[projectId][account][erc20Addr] > 0);
        bool success;
        if (erc20Addr == address(0x0)) {
            (success,) = msg.sender.call{value : _royaltySecondSale[projectId][account][erc20Addr]}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(msg.sender, _royaltySecondSale[projectId][account][erc20Addr]));
        }
        _royaltySecondSaleWithdrawn[projectId][account][erc20Addr] += _royaltySecondSale[projectId][account][erc20Addr];
        emit Royalty.WithdrawRoyalty(account, projectId, erc20Addr);
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
        _royaltySecondSaleAdminWithdrawn[erc20Addr] += _royaltySecondSaleAdmin[erc20Addr];
        emit Royalty.Withdraw(_admin, erc20Addr);
    }

    function setRoyaltySecondSale(uint256 tokenId, address erc20Addr, uint256 amount) external nonReentrant {
        if (_admin == msg.sender || _proxyRoyaltySecondSales[msg.sender]) {
            // get project id from tokenId
            uint256 projectId = tokenId / GenerativeNFTConfigs.PROJECT_PADDING;
            IGenerativeProject project = IGenerativeProject(_generativeProjectAddr);
            // get current owner of project
            address receiver = project.ownerOf(projectId);
            if (receiver != Errors.ZERO_ADDR) {// only apply for generative project
                // 90% for owner of project
                uint256 ownerRoyaltySecondSale = RoyaltyFinanceSecondSaleConfigs.DEFAULT_OWNER_ROYALTY_SECOND_SALE;
                if (_paramsAddress != Errors.ZERO_ADDR) {
                    IParameterControl _p = IParameterControl(_paramsAddress);
                    uint256 projectOwnerRoyalty = _p.getUInt256(RoyaltyFinanceSecondSaleConfigs.OWNER_ROYALTY_SECOND_SALE);
                    if (projectOwnerRoyalty > 0) {
                        ownerRoyaltySecondSale = projectOwnerRoyalty;
                    }
                }
                // set for project's owner
                _royaltySecondSale[projectId][receiver][erc20Addr] += ownerRoyaltySecondSale * amount / Royalty.MINT_PERCENT_ROYALTY;
                // set for _admin
                _royaltySecondSaleAdmin[erc20Addr] = amount - (ownerRoyaltySecondSale * amount / Royalty.MINT_PERCENT_ROYALTY);
                emit Royalty.SetRoyaltySecondSale(msg.sender, tokenId, erc20Addr, amount);
            } else {
                emit Royalty.SetRoyaltySecondSaleFail(msg.sender, tokenId, erc20Addr, amount);
            }
        } else {
            emit Royalty.SetRoyaltySecondSaleFail(msg.sender, tokenId, erc20Addr, amount);
        }
    }

    /* @Support interface
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
        interfaceId == type(IRoyaltyFinanceSecondSale).interfaceId ||
        super.supportsInterface(interfaceId);
    }

    /* @Receive: The Ether received will be logged with {PaymentReceived} events
    */
    receive() external payable virtual {
        require(_admin == msg.sender || _proxyRoyaltySecondSales[msg.sender]);
        emit Royalty.PaymentReceived(msg.sender, msg.value);
    }
}

