pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";
import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IGenerativeNFT.sol";

contract GENTokenTestnet is Initializable, ERC20PausableUpgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, IGENToken, ERC20VotesCompUpgradeable {
    address public _admin;
    address public _paramAddr;
    mapping(address => mapping(address => uint256)) public _claimed;
    mapping(address => mapping(address => uint256)) public _claimedIndex;

    // 60% supply for artist
    uint256 public _remainClaimSupply;

    // 30% supply for team
    uint256 public _remainCoreTeam;

    // 10% supply for DAO
    uint256 public _remainDAO;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramAddr
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;

        uint256 totalSupply = 100 * (10 ** 6) * (10 ** decimals());
        // 60% for artist
        _remainClaimSupply = totalSupply * 60 / 100;
        // 30% for team
        _remainCoreTeam = totalSupply * 30 / 100;
        _mint(_admin, _remainCoreTeam);
        _remainCoreTeam = 0;
        // 10% for DAO
        _remainDAO = totalSupply * 10 / 100;
        _mint(_admin, _remainDAO);
        _remainDAO = 0;

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

    function decay() public view virtual returns (uint8) {
        uint256 decimal = (10 ** 6) * (10 ** decimals());
        uint256 totalSupplyPoA = 60 * decimal - _remainClaimSupply;
        if (totalSupplyPoA < 10 * decimal) {
            return 32;
        } else if (totalSupplyPoA < 20 * decimal) {
            return 16;
        } else if (totalSupplyPoA < 30 * decimal) {
            return 8;
        } else if (totalSupplyPoA < 40 * decimal) {
            return 4;
        } else if (totalSupplyPoA < 50 * decimal) {
            return 2;
        } else if (totalSupplyPoA < 60 * decimal) {
            return 1;
        }
        return 0;
    }

    function proofOfArtAvailable(address generativeProjectAddr, uint256 projectId) public returns (uint256, uint256) {
        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
        NFTProject.Project memory project = projectContract.projectDetails(projectId);
        require(project._mintPriceAddr == Errors.ZERO_ADDR, Errors.POA_INVALID_TOKEN);
        require(project._mintPrice > 0);
        
        IGenerativeNFT nft = IGenerativeNFT(project._genNFTAddr);
        try nft.projectIndex() returns (uint24 index) {
            require(index > 0);
            uint256 amount = (index - _claimedIndex[project._creatorAddr][project._genNFTAddr]) * project._mintPrice;
            return (amount * decay(), index);
        } catch {
            emit NotSupportProjectIndex(project._genNFTAddr);
        }
        return (0, 0);
    }

    /*
    * Project creator call miningPoA function to mint GENToken
    */
    function miningPoA(address generativeProjectAddr, uint256 projectId) external whenNotPaused virtual {
        require(_remainClaimSupply > 0, Errors.REACH_MAX);

        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
        NFTProject.Project memory project = projectContract.projectDetails(projectId);

        // only creator of project
        //        require(receiver == msg.sender, Errors.INV_ADD);

        // PoA only in ETH
        require(project._mintPriceAddr == Errors.ZERO_ADDR, Errors.POA_INVALID_TOKEN);
        require(project._mintPrice > 0);

        // calculate amount
        (uint256 amount, uint256 currentIndex) = proofOfArtAvailable(generativeProjectAddr, projectId);
        if (amount > _remainClaimSupply) {
            amount = _remainClaimSupply;
        }
        // store and mint
        _claimedIndex[project._creatorAddr][project._genNFTAddr] = currentIndex;
        _claimed[project._creatorAddr][project._genNFTAddr] += amount;
        _mint(project._creatorAddr, amount);
        _remainClaimSupply -= amount;

        emit IGENToken.ClaimToken(project._creatorAddr, amount);
    }
}
