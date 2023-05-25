pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../libs/structs/Royalty.sol";
import "../libs/structs/NFTCollection.sol";
import "../libs/structs/NFTProjectData.sol";
import "../interfaces/IParameterControl.sol";
import "../libs/helpers/Base64.sol";
import "../libs/helpers/StringsUtils.sol";
import "../libs/configs/GenerativeProjectDataConfigs.sol";
import "../interfaces/IRandomizer.sol";

contract Solaris is Initializable, ERC721PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IERC2981Upgradeable {

    address public _admin;
    address public _paramsAddress;
    address public _randomizerAddr;
    uint256 private _currentId;
    string public _script;
    address public _brc20Token;
    uint256 public _maxSupply;
    mapping(uint256 => mapping(address => uint256)) public _reservations;

    mapping(uint256 => NFTCollection.OwnerSeed) internal _ownersAndHashSeeds;

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address paramsAddress,
        address randomizerAddr,
        address gmToken
    ) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(paramsAddress != Errors.ZERO_ADDR, Errors.INV_ADD);
        _paramsAddress = paramsAddress;
        _admin = admin;
        _randomizerAddr = randomizerAddr;
        _brc20Token = gmToken;
        _maxSupply = 1000;

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

    function changeBrc20Token(address newBrc20) external {
        require(msg.sender == _admin && newBrc20 != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        if (_brc20Token != newBrc20) {
            _brc20Token = newBrc20;
        }
    }

    function tokenIdToHash(uint256 tokenId) external view returns (bytes32) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        if (_ownersAndHashSeeds[tokenId]._seed == 0) {
            return 0;
        }
        return keccak256(abi.encode(_ownersAndHashSeeds[tokenId]._seed));
    }

    function mint(address to) public payable nonReentrant returns (uint256 tokenId) {
        require(_currentId < _maxSupply, Errors.REACH_MAX);
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _currentId++;
        tokenId = _currentId;
        _safeMint(to, tokenId);

        IRandomizer random = IRandomizer(_randomizerAddr);
        bytes32 seed = random.generateTokenHash(tokenId);
        _setTokenSeed(tokenId, seed);
    }

    function batchMint(address to, uint256 n) external payable returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            uint256 tokenId = mint(to);
            tokenIds[i] = tokenId;
            if (gasleft() < 200000) {break;}
        }
        return tokenIds;
    }

    function _setTokenSeed(uint256 tokenId, bytes32 seed) internal {
        require(_ownersAndHashSeeds[tokenId]._seed == bytes12(0), Errors.TOKEN_HAS_SEED);
        require(seed != bytes12(0), Errors.ZERO_SEED);
        _ownersAndHashSeeds[tokenId]._seed = bytes12(seed);
    }

    function _getBlockReserve() internal returns (uint256) {
        IParameterControl param = IParameterControl(_paramsAddress);
        uint256 blockReserve = param.getUInt256("GM_RESERVE");
        if (blockReserve == 0) {
            // ~block in 7 day, 1 block 10 minute
            blockReserve = 60 * 24 * 7 / 10;
        }
        return blockReserve;
    }

    function reserve(uint256 tokenId) external payable nonReentrant {
        require(claimable(tokenId), "N_C0");

        uint256 blockReserve = _getBlockReserve();
        uint256 reservation = _reservations[tokenId][msg.sender];
        require(reservation == 0 || block.number - reservation >= blockReserve, "N_C0_1");

        _reservations[tokenId][msg.sender] = block.number;
    }

    function claim(uint256 tokenId) external payable nonReentrant {
        require(claimable(tokenId), "N_C1");

        uint256 blockReserve = _getBlockReserve();
        uint256 reservation = _reservations[tokenId][msg.sender];
        require(reservation > 0 && block.number - reservation >= blockReserve, "N_C1_1");

        address owner = ownerOf(tokenId);
        _transfer(owner, msg.sender, tokenId);

        delete _reservations[tokenId][msg.sender];
    }

    function _getBalanceToken(address owner) private view returns (uint256) {
        IERC20Upgradeable brc20TokenGM = IERC20Upgradeable(_brc20Token);
        return brc20TokenGM.balanceOf(owner);
    }

    function _getTokenThreshold() private view returns (uint256) {
        IParameterControl param = IParameterControl(_paramsAddress);
        uint256 threshold = param.getUInt256("GM_THRESHOLD");
        if (threshold == 0) {
            threshold = 1 * 10 ** 18;
        }
        return threshold;
    }

    function claimable(uint256 tokenId) public view virtual returns (bool) {
        // check gm balance
        address owner = ownerOf(tokenId);
        uint256 balanceOwner = _getBalanceToken(owner);
        uint256 balanceClaimer = _getBalanceToken(msg.sender);

        // by threshold on config
        uint256 threshold = _getTokenThreshold();
        if (balanceOwner < threshold && balanceClaimer >= threshold) {
            return true;
        }
        return false;
    }

    function isContract(address _addr) private returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return _ownersAndHashSeeds[tokenId]._owner;
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _ownersAndHashSeeds[tokenId]._owner != Errors.ZERO_ADDR;
    }

    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _ownersAndHashSeeds[tokenId]._owner;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool) {
        address owner = ownerOf(tokenId);
        if (spender != owner) {// case approved
            uint256 balance = _getBalanceToken(owner);
            uint256 threshold = _getTokenThreshold();
            if (balance < threshold) {
                return false;
            }
        }
        return super._isApprovedOrOwner(spender, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        if (msg.sender == from) {
            // is current owner
            uint256 balance = _getBalanceToken(msg.sender);
            uint256 threshold = _getTokenThreshold();
            require(balance >= threshold, "T");
        } else {
            // marketplace(contract) or claimer
            if (isContract(msg.sender)) {
                require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
            } else {
                require(claimable(tokenId), "N_C2");
            }
        }
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        if (msg.sender == from) {
            // is current owner
            uint256 balance = _getBalanceToken(msg.sender);
            uint256 threshold = _getTokenThreshold();
            require(balance >= threshold, "T");
        } else {
            // marketplace(contract) or claimer
            if (isContract(msg.sender)) {
                require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
            } else {
                require(claimable(tokenId), "N_C2");
            }
        }
        _safeTransfer(from, to, tokenId, data);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        super._transfer(from, to, tokenId);
        _ownersAndHashSeeds[tokenId]._owner = to;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory result) {
        require(_exists(tokenId), Errors.INV_TOKEN);
        bytes32 seed = this.tokenIdToHash(tokenId);

        IParameterControl param = IParameterControl(_paramsAddress);
        string memory html = this.tokenHTML(seed);
        NFTProjectData.TokenURIContext memory ctx;
        ctx._animationURI = string(abi.encodePacked(', "animation_url":"', html, '"'));
        ctx._baseURI = param.get(GenerativeProjectDataConfigs.BASE_URI_TRAIT);
        ctx._baseURI = string(abi.encodePacked(ctx._baseURI, "/",
            StringsUpgradeable.toHexString(address(this)), "/",
            StringsUpgradeable.toString(tokenId), "?seed=", StringsUtils.toHex(seed)));
        result = string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(abi.encodePacked(
                    '{"name":"', ctx._name,
                    '","description": "', Base64.encode(abi.encodePacked(ctx._desc)), '"',
                    ', "image": "', ctx._baseURI, '&capture=60000"',
                    ctx._animationURI,
                    ', "attributes": "', ctx._baseURI, '&capture=0"',
                    '}'
                ))
            )
        );
    }

    function tokenHTML(bytes32 seed) external view returns (string memory result) {
        result = _script;
    }

    /** @dev EIP2981 royalties implementation. */
    // EIP2981 standard royalties return.
    function royaltyInfo(uint256 projectId, uint256 _salePrice) external view override
    returns (address receiver, uint256 royaltyAmount){
        receiver = _admin;
        royaltyAmount = (_salePrice * 500) / Royalty.MINT_PERCENT_ROYALTY;
    }
}
