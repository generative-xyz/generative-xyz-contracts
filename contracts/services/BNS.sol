// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/IBNS.sol";
import "../interfaces/IBFS.sol";

    error InsufficientRegistrationFee();
    error NameAlreadyRegistered();
    error AlreadyUpgraded();
    error NotOwner();
    error PfpTooLarge();

contract BNS is IBNS, ERC721Upgradeable, OwnableUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(bytes => uint256) public registry;
    mapping(bytes => bool) public registered;

    mapping(uint256 => address) public resolver;

    uint256 public minRegistrationFee;

    bytes[] public names;
    uint256 _version;

    // v0.3 storage variables
    uint256 public minPfpFee;
    IBFS pfpStorage;
    mapping(uint256 => string) pfps;
    uint256 constant MAX_PFP_SIZE = 380_000;

    // event NameRegistered(bytes name, uint256 indexed id);
    // event ResolverUpdated(uint256 indexed id, address indexed addr);
    event PfpUpdated(uint256 indexed id, string filename);

    function initialize() public initializer {
        __ERC721_init("Bitcoin Name System", "BNS");
        __Ownable_init();
    }

    function afterUpgrade() public {
        if (_version == 4) {
            _version = 5;
        } else {
            revert AlreadyUpgraded();
        }
    }

    function toLower(bytes memory s) internal pure returns (bytes memory) {
        bytes memory result = new bytes(s.length);
        for (uint256 i = 0; i < s.length; i++) {
            if (uint8(s[i]) >= 65 && uint8(s[i]) <= 90) {
                // replace A-Z with a-z; will not affect non-ascii characters
                result[i] = bytes1(uint8(s[i]) + 32);
            } else {
                result[i] = s[i];
            }
        }
        return result;
    }

    function register(address owner, bytes memory name)
    public payable
    returns (uint256)
    {
        name = toLower(name);
        if (msg.value < minRegistrationFee) revert InsufficientRegistrationFee();
        if (registered[name]) revert NameAlreadyRegistered();

        uint256 id = _tokenIds.current();
        _mint(owner, id);
        registry[name] = id;
        registered[name] = true;
        resolver[id] = owner;
        names.push(name);

        emit NameRegistered(name, id);
        emit ResolverUpdated(id, owner);

        _tokenIds.increment();
        return id;
    }

    function registerBatch(address owner, bytes[] memory _names)
    public
    {
        // will revert if any of the names are already registered
        for (uint256 i = 0; i < _names.length; i++) {
            register(owner, _names[i]);
        }
    }


    function map(uint256 tokenId, address to) public {
        require(msg.sender == ownerOf(tokenId));
        resolver[tokenId] = to;
        emit ResolverUpdated(tokenId, to);
    }

    function setMinRegistrationFee(uint256 fee) public onlyOwner {
        minRegistrationFee = fee;
    }

    function getAllNames() public view returns (bytes[] memory) {
        return names;
    }

    function namesLen() public view returns (uint256) {
        return names.length;
    }

    function currentId() public view returns (uint256) {
        return _tokenIds.current();
    }

    function _baseURI() internal view override returns (string memory) {
        return "https://trustless.domains/";
    }


    function setPfp(uint256 tokenId, bytes memory b, string memory _filename) external payable {
        if (b.length > MAX_PFP_SIZE) revert PfpTooLarge();

        if (msg.sender != ownerOf(tokenId)) revert NotOwner();
        if (msg.value < minPfpFee) revert InsufficientRegistrationFee();

        string memory filename;
        if (bytes(_filename).length > 0) {
            filename = string(abi.encodePacked(tokenURI(tokenId), "/", _filename));
        } else {
            filename = tokenURI(tokenId);
        }
        pfps[tokenId] = filename;
        emit PfpUpdated(tokenId, filename);
        pfpStorage.store(filename, 0, b);
    }

    function getPfp(uint256 tokenId) public view returns (bytes memory) {
        string memory filename = pfps[tokenId];
        if (bytes(filename).length == 0) filename = tokenURI(tokenId);
        (bytes memory result, int256 nextChunk) = pfpStorage.load(address(this), filename, 0);
        if (nextChunk != - 1) revert PfpTooLarge();
        return result;
    }

}