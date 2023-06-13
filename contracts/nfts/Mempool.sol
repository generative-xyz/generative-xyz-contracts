pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTCollection.sol";
import "../libs/structs/NFTProjectData.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../interfaces/IRandomizer.sol";
import "../services/BFS.sol";

contract Mempool is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable {

    address public _admin;
    address public _paramsAddress;
    address public _randomizerAddr;
    uint256 private _currentId;
    string public _script;
    uint256 public _maxSupply;

    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;
    mapping(uint256 => uint256) public _mintAt;

    address public _bfs;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address bfs
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _maxSupply = 10;
        _bfs = bfs;

        __ERC721_init(name, symbol);
        __ReentrancyGuard_init();
        __ERC721Pausable_init();
        __Ownable_init();
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

    function changeRandomizerAddr(address newAddr) external {
        require(msg.sender == _admin && newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        // change
        if (_randomizerAddr != newAddr) {
            _randomizerAddr = newAddr;
        }
    }

    function changeScript(string memory newScript) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _script = newScript;
    }

    function changeBfs(address newBfs) external {
        require(msg.sender == _admin && newBfs != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_bfs != newBfs) {
            _bfs = newBfs;
        }
    }

    /* @Mint */
    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    function mint(address to) public payable nonReentrant returns (uint256 tokenId) {
        require(_currentId < _maxSupply, Errors.REACH_MAX);
        require(msg.sender == _admin);
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        IRandomizer random = IRandomizer(_randomizerAddr);
        bytes32 seed = random.generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
        _mintAt[tokenId] = block.number;
    }

    function _setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    /* @Override on ERC-721*/

    function tokenURI(uint256 tokenId) override public view returns (string memory result) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        bytes32 seed = this.tokenIdToHash(tokenId);

        IParameterControl param = IParameterControl(_paramsAddress);
        string memory html = this.tokenHTML(seed, tokenId);
        html = string(abi.encodePacked('data:text/html;base64,', Base64.encode(abi.encodePacked(html))));

        string memory _animationURI = string(abi.encodePacked(', "animation_url":"', html, '"'));
        string memory _baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI_TRAIT);
        _baseURI = string(abi.encodePacked(_baseURI, "/",
            StringsUpgradeable.toHexString(address(this)), "/",
            StringsUpgradeable.toString(tokenId), "?seed=", StringsUtils.toHex(seed)));
        result = string(
            abi.encodePacked(
                '{"name":"","description": ""',
                ', "image": ""',
                _animationURI,
                ', "attributes": ""',
                '}'
            )
        );
    }

    function variableScript(bytes32 seed, uint256 tokenId) public view returns (string memory result) {
        result = "<script id='vars'>";
        result = string(abi.encodePacked(result, "let seed='", StringsUtils.toHex(seed), "';"));
        result = string(abi.encodePacked(result, "let TOKEN_ID='", StringsUpgradeable.toString(tokenId), "';"));
        result = string(abi.encodePacked(result, "</script>"));
    }

    function tokenHTML(bytes32 seed, uint256 tokenId) external view returns (string memory result) {
        result = "<html><head>";
        result = string(abi.encodePacked(result, p5jsScript()));
        result = string(abi.encodePacked(result, variableScript(seed, tokenId)));
        result = string(abi.encodePacked(result, _script));
    }

    function p5jsScript() public view returns (string memory result) {
        result = "<script sandbox='allow-scripts' type='text/javascript'>";

        BFS bfs = BFS(_bfs);
        string memory fileName = "p5js@1.5.0.js";
        // count file
        IParameterControl param = IParameterControl(_paramsAddress);
        address scriptProvider = param.getAddress("SCRIPT_PROVIDER");
        uint256 count = bfs.count(scriptProvider, fileName);
        count += 1;
        // load and concat string
        for (uint256 i = 0; i < count; i++) {
            (bytes memory data, int256 nextChunk) = bfs.load(_admin, fileName, i);
            result = string(abi.encodePacked(result, string(data)));
        }
        result = string(abi.encodePacked(result, "</script>"));
        return result;
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount){
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / Royalty.MINT_PERCENT_ROYALTY;
    }
}
