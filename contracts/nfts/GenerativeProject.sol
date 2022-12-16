pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "../libs/operator-filter-registry/upgradeable/DefaultOperatorFiltererUpgradeable.sol";

import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../interfaces/IGenerativeProjectData.sol";

import "../libs/helpers/Errors.sol";


contract GenerativeProject is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable, IGenerativeProject, DefaultOperatorFiltererUpgradeable {

    // super admin
    address public _admin;
    // parameter control address
    address public _paramsAddress;
    // randomizer
    address public _randomizerAddr;
    // project data
    address public _projectDataContextAddr;

    // projectId is tokenID of project nft
    uint256 private _currentProjectId;

    mapping(uint256 => NFTProject.Project) _projects;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address projectDataContextAddr
    ) initializer public {
        require(admin != address(0), Errors.INV_ADD);
        require(paramsAddress != address(0), Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _projectDataContextAddr = projectDataContextAddr;

        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __DefaultOperatorFilterer_init();
    }

    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }
    }

    function changeParamAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_paramsAddress != newAddr) {
            _paramsAddress = newAddr;
        }
    }

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_randomizerAddr != newAddr) {
            _randomizerAddr = newAddr;
        }
    }

    function changeDataContextAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_projectDataContextAddr != newAddr) {
            _projectDataContextAddr = newAddr;
        }
    }

    function withdraw(address receiver, address erc20Addr, uint256 amount) external nonReentrant {
        require(_msgSender() == _admin, Errors.ONLY_ADMIN_ALLOWED);
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

    /* @Mint project
    */

    function paymentMintProject() internal {
        if (msg.sender != _admin) {
            IParameterControl _p = IParameterControl(_paramsAddress);
            // at least require value 1ETH
            uint256 operationFee = _p.getUInt256("CREATE_PROJECT_FEE");
            if (operationFee > 0) {
                address operationFeeToken = _p.getAddress("FEE_TOKEN");
                if (!(operationFeeToken == address(0))) {
                    IERC20Upgradeable tokenERC20 = IERC20Upgradeable(operationFeeToken);
                    // transfer erc-20 token to this contract
                    require(tokenERC20.transferFrom(
                            msg.sender,
                            address(this),
                            operationFee
                        ));
                } else {
                    require(msg.value >= operationFee);
                }
            }
        }
    }

    function mint(
        NFTProject.Project memory project,
        address[] memory reserves,
        bool disable,
        uint256 openingTime
    ) external payable nonReentrant returns (uint256) {
        // verify
        require(bytes(project._name).length > 3);
        require(bytes(project._creator).length > 3);
        require(project._maxSupply > 0);
        require(project._limit > 0 && project._limit <= project._maxSupply);
        require(project._creatorAddr != Errors.ZERO_ADDR);

        // safe mint
        _currentProjectId++;
        IParameterControl _p = IParameterControl(_paramsAddress);
        paymentMintProject();
        _projects[_currentProjectId] = project;
        _safeMint(msg.sender, _currentProjectId);

        // set to generative nft
        address generativeNFTAdd = ClonesUpgradeable.clone(_p.getAddress("GENERATIVE_NFT_TEMPLATE"));
        _projects[_currentProjectId]._genNFTAddr = generativeNFTAdd;
        IGenerativeNFT nft = IGenerativeNFT(generativeNFTAdd);
        nft.init(
            NFTProject.ProjectMinting(
                address(this),
                _currentProjectId,
                project._maxSupply,
                project._limit,
                0,
                0,
                project._creator,
                project._creatorAddr,
                project._mintPrice,
                project._mintPriceAddr,
                project._name,
                NFTProject.ProjectMintingSchedule(0, openingTime)
            ), _admin, _paramsAddress, _randomizerAddr, _projectDataContextAddr, reserves, disable);
        return _currentProjectId;
    }

    function updateProjectScriptType(
        uint256 projectId,
        string memory scriptType,
        uint256 i
    )
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._scriptType[i] = scriptType;
    }

    function addProjectScript(uint256 projectId, string memory _script)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._scripts.push(_script);
    }

    function updateProjectScript(uint256 projectId, uint256 scriptIndex, string memory script)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._scripts[scriptIndex] = script;
    }

    function deleteProjectScript(uint256 projectId, uint256 scriptIndex)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        delete _projects[projectId]._scripts[scriptIndex];
    }

    function completeProject(uint256 projectId) external {
        require(msg.sender == _projects[projectId]._genNFTAddr);
        _projects[projectId]._completeTime = block.timestamp;
    }

    function updateProjectName(uint256 projectId, string memory projectName)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._name = projectName;
    }

    function updateProjectCreatorName(uint256 projectId, string memory creatorName)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._creator = creatorName;
    }

    function updateProjectLicense(uint256 projectId, string memory license)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._license = license;
    }

    function setProjectStatus(uint256 projectId, bool enable) external {
        require(this.projectStatus(projectId) != enable);
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        nft.setStatus(enable);
    }

    /* @projectData:
    */
    function projectDetails(uint256 projectId) external view returns (NFTProject.Project memory project){
        project = _projects[projectId];
    }

    function projectStatus(uint256 projectId) external view returns (bool enable) {
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        enable = nft.getStatus();
    }

    function tokenURI(uint256 projectId) override public view returns (string memory result) {
        IGenerativeProjectData projectData = IGenerativeProjectData(_projectDataContextAddr);
        result = projectData.projectURI(projectId);
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / 10000;
    }

    /* @notice: opensea operator filter registry
    */
    function transferFrom(address from, address to, uint256 tokenId) public override(IERC721Upgradeable, ERC721Upgradeable) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override(IERC721Upgradeable, ERC721Upgradeable) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
    public
    override(IERC721Upgradeable, ERC721Upgradeable)
    onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
