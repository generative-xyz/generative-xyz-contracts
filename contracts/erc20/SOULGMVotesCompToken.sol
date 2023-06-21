pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";
import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../libs/structs/Marketplace.sol";
import "../nfts/GenerativeNFT.sol";

contract SOULGMVotesCompToken is Initializable, ERC20PausableUpgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, ERC20VotesCompUpgradeable, ReentrancyGuardUpgradeable {
    address public _admin;
    address public _paramAddr;
    address public _gmToken;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramAddr,
        address gmToken
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;
        _gmToken = gmToken;

        __ERC20Pausable_init();
        __ERC20_init(name, symbol);
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeGMToken(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        if (_gmToken != newAddr) {
            _gmToken = newAddr;
        }
    }

    function changeParamAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        if (_paramAddr != newAddr) {
            _paramAddr = newAddr;
        }
    }

    // @MintAndBurn: base on gm token
    function mint(uint256 amount) public nonReentrant {
        require(IERC20Upgradeable(_gmToken).transferFrom(msg.sender, address(this), amount));
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public nonReentrant {
        require(balanceOf(msg.sender) >= amount);
        require(IERC20Upgradeable(_gmToken).transfer(msg.sender, amount));
        _burn(msg.sender, amount);
    }

    /* @OVERRIDE: 
    */
    function name() public view virtual override returns (string memory) {
        return "SOULGMVotesCompToken";
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override(ERC20Upgradeable) returns (uint256) {
        return super.totalSupply();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
    internal
    override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }
}
