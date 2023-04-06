// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

    error InsufficientRegistrationFee();
    error NameAlreadyRegistered();

contract BNS is ERC721Upgradeable, OwnableUpgradeable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(bytes => uint256) public registry;
    mapping(bytes => bool) public registered;

    mapping(uint256 => address) public resolver;
    uint256 public minRegistrationFee = 0 ether;

    bytes[] public names;

    event NameRegistered(bytes name, uint256 indexed id);

    function initialize() public initializer {
        __ERC721_init("Bitcoin Name System", "BNS");
        __Ownable_init();
    }

    function afterUpgrade(bytes[] memory _names) public {
        for (uint256 i = 0; i < _names.length; i++) {
            if (registered[_names[i]]) {
                names.push(_names[i]);
            }
        }
    }


    function register(address owner, bytes memory name)
    public payable
    returns (uint256)
    {
        if (msg.value < minRegistrationFee) revert InsufficientRegistrationFee();
        if (registered[name]) revert NameAlreadyRegistered();

        uint256 id = _tokenIds.current();
        _mint(owner, id);
        registry[name] = id;
        registered[name] = true;
        resolver[id] = owner;
        names.push(name);
        emit NameRegistered(name, id);

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
}