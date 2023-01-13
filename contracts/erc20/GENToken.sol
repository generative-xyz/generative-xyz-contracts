pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";
import "../interfaces/IGenerativeProject.sol";
import "../nfts/GenerativeNFT.sol";

contract GENToken is Initializable, ERC20PausableUpgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, IGENToken, ERC20VotesCompUpgradeable {
    address public _admin;
    address public _paramAddr;
    mapping(address => mapping(address => uint256)) public _claimed;
    uint256 public _remainSupply;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramAddr,
        uint256 initSupply
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;

        _remainSupply = 100 * 1e6 * 1e18;

        __ERC20Pausable_init();
        __ERC20_init(name, symbol);
        __Ownable_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParamAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change param address
        if (_paramAddr != newAddr) {
            _admin = newAddr;
        }
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public view override(ERC20Upgradeable, IERC20Upgradeable) returns (uint256) {
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

    /*
    * @Minting
    */
    function calculateAmount(address genNFTAddr, uint256 mintPrice) internal returns (uint256) {
        GenerativeNFT nft = GenerativeNFT(genNFTAddr);
        try nft.projectIndex() returns (uint24 index) {
            uint256 revenue = index * mintPrice - _claimed[msg.sender][genNFTAddr];
            _claimed[msg.sender][genNFTAddr] += revenue;
            return revenue;
        } catch {

        }
        return 0;
    }

    /*
    * Project creator call claim function to mint GENToken
    */
    function claim(address generativeProjectAddr, uint256 projectId) external whenNotPaused virtual {
        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
        NFTProject.Project memory project = projectContract.projectDetails(projectId);
        require(project._creatorAddr == msg.sender, Errors.INV_ADD);
        uint256 amount = calculateAmount(project._genNFTAddr, project._mintPrice);
        if (amount > _remainSupply) {
            amount = _remainSupply;
        }
        _mint(msg.sender, amount);
        _remainSupply -= amount;
        emit IGENToken.ClaimToken(msg.sender, amount);
    }
}
