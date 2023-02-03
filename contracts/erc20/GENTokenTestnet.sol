pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";
import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../libs/structs/Marketplace.sol";
import "../nfts/GenerativeNFT.sol";

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

    // Proof of Art base on second sale(marketplace)
    mapping(address => mapping(address => uint256)) public _PoASecondSale;
    mapping(address => bool) public _proxyPoASecondSales;


    // vesting time
    uint256 public _teamVesting;
    uint256 public _daoVesting;

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
            _paramAddr = newAddr;
        }
    }

    function setProxyPoASecondSale(address addr, bool approve) external {
        require(msg.sender == _admin && addr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // set approve
        _proxyPoASecondSales[addr] = approve;
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

    function setPoASecondSale(address genNFTAddr, uint256 tokenId, address erc20Addr, uint256 amount) external {
        if (_admin == msg.sender || _proxyPoASecondSales[msg.sender]) {
            // PoA only in ETH
            if (erc20Addr == Errors.ZERO_ADDR) {
                IGenerativeNFT nft = IGenerativeNFT(genNFTAddr);
                // try access project minting info of genNFTAddr
                try nft.projectAddress() returns (address generativeProjectAddr) {
                    // get project id from tokenId
                    uint256 projectId = tokenId / GenerativeNFTConfigs.PROJECT_PADDING;
                    IGenerativeProject project = IGenerativeProject(generativeProjectAddr);
                    // get current owner of project
                    address receiver = project.ownerOf(projectId);
                    if (receiver != Errors.ZERO_ADDR) {// only apply for generative project
                        // set for current owner of project
                        NFTProject.Project memory d = project.projectDetails(projectId);
                        _PoASecondSale[receiver][d._genNFTAddr] += amount;
                    }
                } catch {
                    emit NotSupportProjectAddress(genNFTAddr);
                }
            }
        }
    }

    function proofOfArtAvailable(address generativeProjectAddr, uint256 projectId) public returns (uint256, uint256, uint256) {
        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
        NFTProject.Project memory project = projectContract.projectDetails(projectId);
        require(project._mintPriceAddr == Errors.ZERO_ADDR, Errors.POA_INVALID_TOKEN);
        require(project._mintPrice > 0);

        IGenerativeNFT nft = IGenerativeNFT(project._genNFTAddr);
        try nft.projectIndex() returns (uint24 index) {
            require(index > 0);
            uint256 PoAPrimarySale = (index - _claimedIndex[projectContract.ownerOf(projectId)][project._genNFTAddr]) * project._mintPrice;
            // x 1000 for testnet
            return (PoAPrimarySale * decay() * 100, index, _PoASecondSale[projectContract.ownerOf(projectId)][project._genNFTAddr] * decay() * 100);
        } catch {
            emit NotSupportProjectIndex(project._genNFTAddr);
        }
        return (0, 0, 0);
    }

    /*
    * Project creator call miningPoA function to mint GENToken
    */
    function miningPoA(address generativeProjectAddr, uint256 projectId) external whenNotPaused virtual {
        require(_remainClaimSupply > 0, Errors.REACH_MAX);

        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
        NFTProject.Project memory project = projectContract.projectDetails(projectId);

        // only creator of project
        //        require(project.ownerOf(projectId) == msg.sender, Errors.INV_ADD);

        // PoA only in ETH
        require(project._mintPriceAddr == Errors.ZERO_ADDR, Errors.POA_INVALID_TOKEN);
        require(project._mintPrice > 0);

        // calculate amount
        (uint256 primarySale, uint256 currentIndex, uint256 secondSale) = proofOfArtAvailable(generativeProjectAddr, projectId);
        uint256 amount = primarySale + secondSale;
        if (amount > 0) {
            if (amount > _remainClaimSupply) {
                amount = _remainClaimSupply;
            }
            // store and mint
            _claimedIndex[project._creatorAddr][project._genNFTAddr] = currentIndex;
            _claimed[project._creatorAddr][project._genNFTAddr] += amount;
            _PoASecondSale[projectContract.ownerOf(projectId)][project._genNFTAddr] = 0;
            _mint(project._creatorAddr, amount);
            _remainClaimSupply -= amount;

            emit IGENToken.ClaimToken(project._creatorAddr, amount, primarySale, currentIndex, secondSale);
        }
    }

    function miningTeam() external whenNotPaused virtual {
        //        require(_remainCoreTeam > 0, Errors.VESTING_REMAIN);
        _burn(msg.sender, 10);
        _remainCoreTeam = 10;
        require(block.number - _teamVesting > 100, Errors.VESTING_TIME_LOCK);

        IParameterControl p = IParameterControl(_paramAddr);
        address team = p.getAddress(GENDaoConfigs.TEAM_VESTING);
        require(team != Errors.ZERO_ADDR, Errors.TEAM_VESTING_ERROR_ADDR);

        uint256 available = _remainCoreTeam;
        _mint(team, available);
        _remainCoreTeam -= available;
        _teamVesting = block.number;
    }

    function miningDAOTreasury() external whenNotPaused virtual {
        //        require(_remainDAO > 0, Errors.VESTING_REMAIN);
        _burn(msg.sender, 10);
        _remainDAO = 10;
        require(block.number - _daoVesting > 100, Errors.VESTING_TIME_LOCK);

        IParameterControl p = IParameterControl(_paramAddr);
        address daoTreasury = p.getAddress(GENDaoConfigs.OPERATOR_TREASURE_ADDR);
        require(daoTreasury != Errors.ZERO_ADDR, Errors.DAO_VESTING_ERROR_ADDR);

        uint256 available = _remainDAO;
        _mint(daoTreasury, available);
        _remainDAO -= available;
        _daoVesting = block.number;
    }
}
