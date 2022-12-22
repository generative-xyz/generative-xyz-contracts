pragma solidity ^0.8.0;

// external libs
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// inheritance and interface
import "./BaseERC721OwnerSeed.sol";
import "../interfaces/IGenerativeProject.sol";
import "../interfaces/IGenerativeNFT.sol";
import "../interfaces/IParameterControl.sol";
import "../interfaces/IGenerativeProjectData.sol";
import "../libs/operator-filter-registry/DefaultOperatorFilterer.sol";

// libs
import "../libs/configs/GenerativeNFTConfigs.sol";
import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTProject.sol";

// services
import "../services/Randomizer.sol";


contract GenerativeNFT is BaseERC721OwnerSeed, IGenerativeNFT, DefaultOperatorFilterer {
    NFTProject.ProjectMinting public _project;
    mapping(address => bool) private _reserves;

    constructor (string memory name, string memory symbol)
    BaseERC721OwnerSeed(name, symbol) DefaultOperatorFilterer() {}

    function owner() public view override returns (address) {
        return _admin;
    }

    function _checkOwner() internal view override {
        require(owner() == msg.sender || msg.sender == _project._projectAddr, "Ownable: caller is not the owner");
    }

    /* @ProjectInfo: data for project data
    */
    function init(NFTProject.ProjectMinting memory project, address admin, address paramsAddr, address randomizer, address projectDataContextAddr, address[] memory reserves, bool disable, uint256 royalty) external {
        require(_admin == Errors.ZERO_ADDR, Errors.INV_PROJECT);
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        _project = project;
        _paramsAddress = paramsAddr;
        _admin = admin;
        _randomizer = randomizer;
        _projectDataContextAddr = projectDataContextAddr;
        _nameCol = string(abi.encodePacked(project._name, " by ", project._creator));
        for (uint256 i;
            i < reserves.length;
            i++) {
            _reserves[reserves[i]] = true;
        }
        transferOwnership(_admin);
        if (disable) {
            _pause();
        }
        _project._mintingSchedule._initBlockTime = block.timestamp;
        _royalty = royalty;
    }

    /* @Mint
    */
    function setStatus(bool enable) external {
        require(msg.sender == _admin || msg.sender == _project._projectAddr, Errors.ONLY_ADMIN_ALLOWED);
        super._setStatus(enable);
    }

    function setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    function paymentMintNFT() internal {
        uint256 mintPrice = _project._mintPrice;
        if (mintPrice == 0) {
            return;
        }

        IGenerativeProject project = IGenerativeProject(_project._projectAddr);
        IParameterControl _p = IParameterControl(_paramsAddress);
        // default 5% getting, 95% pay for owner of project
        uint256 operationFee = _p.getUInt256(GenerativeNFTConfigs.DEFAULT_ROYALTY_FIN_PERCENT);
        // default is admin should get operationFee
        address operatorTreasureAddress = _admin;
        if (_paramsAddress != address(0)) {
            operationFee = _p.getUInt256(GenerativeNFTConfigs.MINT_NFT_OPERATOR_FEE);
            address operatorTreasureConfig = _p.getAddress(GenerativeNFTConfigs.MINT_NFT_OPERATOR_TREASURE_ADDR);
            if (operatorTreasureConfig != Errors.ZERO_ADDR) {
                operatorTreasureAddress = operatorTreasureConfig;
            }
        }
        // check mintPrice using erc-20
        address mintPriceAddr = _project._mintPriceAddr;
        if (mintPriceAddr == Errors.ZERO_ADDR) {
            require(msg.value >= mintPrice);

            // pay for owner project
            (bool success,) = project.ownerOf(_project._projectId).call{value : mintPrice - (mintPrice * operationFee / 10000)}("");
            require(success);
            if (operationFee > 0) {
                // pay for admin
                (success,) = operatorTreasureAddress.call{value : mintPrice * operationFee / 10000}("");
            }
        } else {
            IERC20 tokenERC20 = IERC20(mintPriceAddr);
            // transfer all fee erc-20 token to this contract
            require(tokenERC20.transferFrom(
                    msg.sender,
                    address(this),
                    mintPrice
                ));

            // pay for owner project
            require(tokenERC20.transfer(project.ownerOf(_project._projectId), mintPrice - (mintPrice * operationFee / 10000)));
            if (operationFee > 0) {
                // pay for admin
                require(tokenERC20.transfer(operatorTreasureAddress, mintPrice * operationFee / 10000));
            }
        }
    }

    function mint() external payable nonReentrant returns (uint256 tokenId) {
        // check time
        if (_project._mintingSchedule._openingTime > 0) {
            require(_project._mintingSchedule._openingTime < block.timestamp, Errors.OPENING_SCHEDULE);
        }
        // safe mint
        _project._index ++;
        require(_project._index <= _project._limit);
        if (_project._index + _project._indexReserve == _project._maxSupply) {
            IGenerativeProject p = IGenerativeProject(_project._projectAddr);
            p.completeProject(_project._projectId);
        }
        tokenId = (_project._projectId * GenerativeNFTConfigs.PROJECT_PADDING) + _project._index;
        _safeMint(msg.sender, tokenId);

        // random seed
        IRandomizer random = IRandomizer(_randomizer);
        bytes32 seed = random.generateTokenHash(tokenId);
        setTokenSeed(tokenId, seed);

        // pay
        paymentMintNFT();

        emit NFTCollection.Mint(msg.sender, tokenId);
    }

    function reserveMint() external payable nonReentrant returns (uint256 tokenId) {
        _project._indexReserve ++;
        require(_project._indexReserve + _project._limit <= _project._maxSupply);
        if (_project._index + _project._indexReserve == _project._maxSupply) {
            IGenerativeProject p = IGenerativeProject(_project._projectAddr);
            p.completeProject(_project._projectId);
        }

        IGenerativeProject p = IGenerativeProject(_project._projectAddr);
        // is owner of project or reserve list
        require(_reserves[msg.sender] || msg.sender == p.ownerOf(_project._projectId));
        if (_reserves[msg.sender] && _project._mintingSchedule._openingTime > 0) {
            require(_project._mintingSchedule._openingTime < block.timestamp, Errors.OPENING_SCHEDULE);
        }
        tokenId = (_project._projectId * GenerativeNFTConfigs.PROJECT_PADDING) + (_project._indexReserve + _project._limit);
        _safeMint(msg.sender, tokenId);

        // random seed
        IRandomizer random = IRandomizer(_randomizer);
        bytes32 seed = random.generateTokenHash(tokenId);
        setTokenSeed(tokenId, seed);

        // no paymentMintNFT

        emit NFTCollection.Mint(msg.sender, tokenId);
    }

    /* @TokenData:
    */

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        IGenerativeProjectData projectData = IGenerativeProjectData(_projectDataContextAddr);
        bytes32 seed = this.tokenIdToHash(tokenId);
        return projectData.tokenBaseURI(_project._projectId, tokenId, seed);
    }

    function tokenGenerativeURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        IGenerativeProjectData projectData = IGenerativeProjectData(_projectDataContextAddr);
        bytes32 seed = this.tokenIdToHash(tokenId);
        return projectData.tokenURI(_project._projectId, tokenId, seed);
    }

    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    /* @notice: opensea operator filter registry
    */
    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
    public
    override
    onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
