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

import "../libs/configs/GenerativeProjectConfigs.sol";
import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/configs/GENDaoConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";


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

    address public _projectImplementation;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address projectDataContextAddr
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _projectDataContextAddr = projectDataContextAddr;

        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __DefaultOperatorFilterer_init();
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

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_randomizerAddr != newAddr) {
            _randomizerAddr = newAddr;
        }
    }

    function changeDataContextAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_projectDataContextAddr != newAddr) {
            _projectDataContextAddr = newAddr;
        }
    }

    /*function withdraw(address erc20Addr, uint256 amount) external nonReentrant {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        address operatorTreasureAddress = msg.sender;
        IParameterControl _p = IParameterControl(_paramsAddress);
        address operatorTreasureConfig = _p.getAddress(GENDaoConfigs.OPERATOR_TREASURE_ADDR);
        if (operatorTreasureConfig != Errors.ZERO_ADDR) {
            operatorTreasureAddress = operatorTreasureConfig;
        }
        bool success;
        if (erc20Addr == address(0x0)) {
            require(address(this).balance >= amount);
            (success,) = operatorTreasureAddress.call{value : amount}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(operatorTreasureAddress, amount));
        }
    }*/

    function withdraw(address receiver, address erc20Addr, uint256 amount) external nonReentrant {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
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

    function _paymentMintProject() internal {
        if (msg.sender != _admin) {
            IParameterControl _p = IParameterControl(_paramsAddress);
            // at least require value 1ETH
            uint256 operationFee = _p.getUInt256(GenerativeProjectConfigs.CREATE_PROJECT_FEE);
            if (operationFee > 0) {
                address operationFeeToken = _p.getAddress(GenerativeProjectConfigs.FEE_TOKEN);
                address operatorTreasureAddress = address(this);
                address operatorTreasureConfig = _p.getAddress(GENDaoConfigs.OPERATOR_TREASURE_ADDR);
                if (operatorTreasureConfig != Errors.ZERO_ADDR) {
                    operatorTreasureAddress = operatorTreasureConfig;
                }
                if (!(operationFeeToken == Errors.ZERO_ADDR)) {
                    IERC20Upgradeable tokenERC20 = IERC20Upgradeable(operationFeeToken);
                    // transfer erc-20 token to this contract
                    require(tokenERC20.transferFrom(
                            msg.sender,
                            operatorTreasureAddress,
                            operationFee
                        ));
                } else {
                    require(msg.value >= operationFee);
                    (bool success,) = operatorTreasureAddress.call{value : msg.value}("");
                    require(success);
                }
            }
        }
    }

    function mint(
        NFTProject.Project memory project,
        bool disable,
        uint256 openingTime
    ) external payable nonReentrant returns (uint256) {
        // verify
        require(bytes(project._name).length > 3 && bytes(project._creator).length > 3 && bytes(project._image).length > 0, Errors.MISSING_NAME);
        require(project._maxSupply > 0 && project._maxSupply < GenerativeNFTConfigs.PROJECT_PADDING && project._limit > 0 && project._limit <= project._maxSupply && project._royalty <= Royalty.MINT_PERCENT_ROYALTY, Errors.INV_PARAMS);
        require(project._creatorAddr != Errors.ZERO_ADDR, Errors.INV_ADD);

        // safe mint
        _currentProjectId++;
        IParameterControl _p = IParameterControl(_paramsAddress);
        _paymentMintProject();
        _projects[_currentProjectId] = project;
        _safeMint(project._creatorAddr, _currentProjectId);

        // set to generative nft
        address generativeNFTAdd = ClonesUpgradeable.clone(_p.getAddress(GenerativeProjectConfigs.GENERATIVE_NFT_TEMPLATE));
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
                project._mintPrice,
                project._mintPriceAddr,
                project._name,
                NFTProject.ProjectMintingSchedule(0, openingTime),
                project._reserves,
                project._royalty
            ), _admin, _paramsAddress, _randomizerAddr, _projectDataContextAddr, disable);
        return _currentProjectId;
    }

    function updateProjectScriptType(
        uint256 projectId,
        string memory scriptType,
        uint256 i
    )
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._scriptType[i] = scriptType;
    }

    /* @UpdateProject
    */
    function addProjectScript(uint256 projectId, string memory _script)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._scripts.push(_script);
    }

    function updateProjectScript(uint256 projectId, uint256 scriptIndex, string memory script)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._scripts[scriptIndex] = script;
    }

    function deleteProjectScript(uint256 projectId, uint256 scriptIndex)
    external
    {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        delete _projects[projectId]._scripts[scriptIndex];
    }

    function completeProject(uint256 projectId)
    external {
        require(msg.sender == _projects[projectId]._genNFTAddr);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._completeTime = block.timestamp;
        emit NFTProject.CompleteProject(projectId, _projects[projectId]._completeTime);
    }

    function updateProjectName(uint256 projectId, string memory projectName)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._name = projectName;
        emit NFTProject.UpdateProjectName(projectId, projectName);
    }

    function updateProjectCreatorName(uint256 projectId, string memory creatorName)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._creator = creatorName;
        emit NFTProject.UpdateProjectCreatorName(projectId, creatorName);
    }

    function updateProjectLicense(uint256 projectId, string memory license)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._license = license;
        emit NFTProject.UpdateProjectLicense(projectId, license);
    }

    function setProjectStatus(uint256 projectId, bool enable) external {
        require(_exists(projectId), Errors.INV_TOKEN);
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        require(nft.getStatus() != enable);
        nft.setStatus(enable);
        emit NFTProject.SetProjectStatus(projectId, enable);
    }

    function updateProjectSocial(uint256 projectId, NFTProject.ProjectSocial memory data)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._social._discord = data._discord;
        _projects[projectId]._social._twitter = data._twitter;
        _projects[projectId]._social._instagram = data._instagram;
        _projects[projectId]._social._medium = data._medium;
        _projects[projectId]._social._web = data._web;
        emit NFTProject.UpdateProjectSocial(projectId, data);
    }

    function updateProjectPrice(uint256 projectId, uint256 price)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._mintPrice = price;
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        nft.updatePrice(price);
        emit NFTProject.UpdateProjectPrice(projectId, price);
    }

    function updateProjectPriceAddress(uint256 projectId, address priceAddress)
    external {
        require(msg.sender == _admin || msg.sender == _projects[projectId]._creatorAddr, Errors.ONLY_ADMIN_ALLOWED);
        require(_exists(projectId), Errors.INV_TOKEN);
        _projects[projectId]._mintPriceAddr = priceAddress;
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        nft.updatePriceAddress(priceAddress);
        emit NFTProject.UpdateProjectPriceAddress(projectId, priceAddress);
    }

    /* @OverrideTransfer: project can mint but can not transfer
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId, /* firstTokenId */
        uint256 batchSize
    ) internal override {
        // project can mint but can not transfer
        require(from == Errors.ZERO_ADDR, Errors.FORBIDDEN_TRANSFER_PROJECT);
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /* @projectDataURI
    */
    function projectDetails(uint256 projectId) external view returns (NFTProject.Project memory project){
        require(_exists(projectId), Errors.INV_TOKEN);
        project = _projects[projectId];
    }

    function projectStatus(uint256 projectId) external view returns (bool enable) {
        require(_exists(projectId), Errors.INV_TOKEN);
        IGenerativeNFT nft = IGenerativeNFT(_projects[projectId]._genNFTAddr);
        enable = nft.getStatus();
        enable = enable && (_projects[projectId]._completeTime == 0);
    }

    function tokenURI(uint256 projectId) override public view returns (string memory result) {
        require(_exists(projectId), Errors.INV_TOKEN);
        IGenerativeProjectData projectData = IGenerativeProjectData(_projectDataContextAddr);
        result = projectData.projectURI(projectId);
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount)
    {
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / Royalty.MINT_PERCENT_ROYALTY;
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

    function getGenerativeNFTImpl() external view returns (address impl) {
        impl = _projectImplementation;
    }
}
