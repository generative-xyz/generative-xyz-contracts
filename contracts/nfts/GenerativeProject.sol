pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "../interfaces/IGenerativeProject.sol";
import "../libs/helpers/Errors.sol";
import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../interfaces/IGenerativeProjectData.sol";

contract GenerativeProject is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, IERC2981Upgradeable, IGenerativeProject {

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
        address paramsAddress
    ) initializer public {
        require(admin != address(0), Errors.INV_ADD);
        require(paramsAddress != address(0), Errors.INV_ADD);
        __ERC721_init(name, symbol);
        _paramsAddress = paramsAddress;
        _admin = admin;
    }

    function changeAdmin(address newAdm, address newParam) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);

        // change admin
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }

        // change param
        require(newParam != address(0));
        if (_paramsAddress != newParam) {
            _paramsAddress = newParam;
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
        address[] memory reserves
    ) external returns (uint256) {
        // verify
        require(bytes(project._name).length > 0);
        require(bytes(project._creator).length > 0);
        require(project._maxSupply > 0);
        require(project._limit > 0 && project._limit <= project._maxSupply);
        require(project._creatorAddr != address(0x0));

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
        NFTProject.ProjectMinting memory data;
        nft.init(data, _admin, _paramsAddress, _randomizerAddr, reserves);
        return _currentProjectId;
    }

    function updateProjectScriptType(
        uint256 projectId,
        string memory scriptType
    )
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr);
        _projects[projectId]._scriptType = scriptType;
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

    /* @projectData:
    */
    function projectDetails(uint256 projectId) external view returns (NFTProject.Project memory project){
        project = _projects[projectId];
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
}
