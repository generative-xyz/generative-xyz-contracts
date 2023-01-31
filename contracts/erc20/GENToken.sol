pragma solidity ^0.8.0;

//import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesCompUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";
//
//import "../libs/helpers/Errors.sol";
//import "../interfaces/IGENToken.sol";
//import "../interfaces/IGenerativeProject.sol";
//import "../interfaces/IGenerativeNFT.sol";
//
//contract GENToken is Initializable, ERC20PausableUpgradeable, ERC20BurnableUpgradeable, OwnableUpgradeable, IGENToken, ERC20VotesCompUpgradeable {
//    address public _admin;
//    address public _paramAddr;
//    mapping(address => mapping(address => uint256)) public _claimed;
//
//    // 60% supply for artist
//    uint256 public _remainClaimSupply;
//
//    // 30% supply for team
//    uint256 public _remain;
//
//    function initialize(
//        string memory name,
//        string memory symbol,
//        address admin,
//        address paramAddr
//    ) initializer public {
//        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
//        _admin = admin;
//        _paramAddr = paramAddr;
//
//        uint256 totalSupply = 100 * (10 ** 6) * (10 ** decimals());
//        // 70% for artist
//        _remainClaimSupply = totalSupply * 60 / 100;
//        // 20% for team
//        uint256 _coreTeam = totalSupply * 20 / 100;
//        _mint(_admin, _coreTeam);
//        // 10% for testnet
//
//        __ERC20Pausable_init();
//        __ERC20_init(name, symbol);
//        __Ownable_init();
//    }
//
//    function changeAdmin(address newAdm) external {
//        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
//        // change admin
//        if (_admin != newAdm) {
//            _admin = newAdm;
//        }
//    }
//
//    function changeParamAddress(address newAddr) external {
//        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
//        // change param address
//        if (_paramAddr != newAddr) {
//            _admin = newAddr;
//        }
//    }
//
//    function decimals() public pure override returns (uint8) {
//        return 18;
//    }
//
//    function totalSupply() public view override(ERC20Upgradeable, IERC20Upgradeable) returns (uint256) {
//        return super.totalSupply();
//    }
//
//    function _beforeTokenTransfer(address from, address to, uint256 amount)
//    internal
//    override(ERC20Upgradeable, ERC20PausableUpgradeable)
//    {
//        super._beforeTokenTransfer(from, to, amount);
//    }
//
//    function _afterTokenTransfer(address from, address to, uint256 amount)
//    internal
//    override(ERC20Upgradeable, ERC20VotesUpgradeable)
//    {
//        super._afterTokenTransfer(from, to, amount);
//    }
//
//    function _mint(address to, uint256 amount)
//    internal
//    override(ERC20Upgradeable, ERC20VotesUpgradeable)
//    {
//        super._mint(to, amount);
//    }
//
//    function _burn(address account, uint256 amount)
//    internal
//    override(ERC20Upgradeable, ERC20VotesUpgradeable)
//    {
//        super._burn(account, amount);
//    }
//
//    /*
//    * @Minting
//    */
//    function proofOfArt(address genNFTAddr, uint256 mintPrice) public returns (uint256) {
//        IGenerativeNFT nft = IGenerativeNFT(genNFTAddr);
//        try nft.projectIndex() returns (uint24 index) {
//            return index * mintPrice - _claimed[msg.sender][genNFTAddr];
//        } catch {
//            emit NotSupportProjectIndex(genNFTAddr);
//        }
//        return 0;
//    }
//
//    /*
//    * Project creator call claim function to mint GENToken
//    */
//    function claim(address generativeProjectAddr, uint256 projectId) external whenNotPaused virtual {
//        require(_remainClaimSupply > 0, Errors.REACH_MAX);
//
//        IGenerativeProject projectContract = IGenerativeProject(generativeProjectAddr);
//        NFTProject.Project memory project = projectContract.projectDetails(projectId);
//        require(project._creatorAddr == msg.sender, Errors.INV_ADD);
//
//        uint256 amount = proofOfArt(project._genNFTAddr, project._mintPrice);
//        if (amount > _remainClaimSupply) {
//            amount = _remainClaimSupply;
//        }
//        _claimed[msg.sender][project._genNFTAddr] += amount;
//        _mint(msg.sender, amount);
//        _remainClaimSupply -= amount;
//
//        emit IGENToken.ClaimToken(msg.sender, amount);
//    }
//}
