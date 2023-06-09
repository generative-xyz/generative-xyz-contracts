// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IBFS.sol";

    error FileExists();
    error InvalidURI();
    error InvalidBfsResult();



contract BFS is IBFS, Initializable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;

    Counters.Counter private idCounter;
    mapping(address => mapping(string => mapping(uint256 => bytes))) public dataStorage;
    mapping(address => mapping(string => uint256)) public chunks; // max chunk index
    mapping(address => mapping(string => uint256)) public bfsId;

    mapping(address => string[]) public filenames;
    EnumerableSet.AddressSet addresses;

    // event FileStored(address indexed addr, string filename, uint256 chunkIndex, uint256 indexed bfsId, string uri);

    function initialize() public initializer {
        idCounter.increment();
        // start from 1
    }

    function store(string memory filename, uint256 chunkIndex, bytes memory _data) external {
        if (dataStorage[msg.sender][filename][chunkIndex].length > 0) {
            revert FileExists();
        }
        dataStorage[msg.sender][filename][chunkIndex] = _data;
        if (chunks[msg.sender][filename] < chunkIndex) {
            chunks[msg.sender][filename] = chunkIndex;
        }
        bfsId[msg.sender][filename] = idCounter.current();
        idCounter.increment();

        if (chunkIndex == 0) {
            filenames[msg.sender].push(filename);
            addresses.add(msg.sender);
        }

        string memory uri = string.concat(
            "bfs://",
            Strings.toString(block.chainid),
            "/",
            Strings.toHexString(address(this)),
            "/",
            Strings.toHexString(msg.sender),
            "/",
            filename
        );
        emit FileStored(msg.sender, filename, chunkIndex, bfsId[msg.sender][filename], uri);
    }

    function load(address addr, string memory filename, uint256 chunkIndex) public view returns (bytes memory, int256) {
        uint256 temp = chunkIndex + 1;
        int256 nextChunk = (temp > chunks[addr][filename]) ? - 1 : int256(temp);
        return (dataStorage[addr][filename][chunkIndex], nextChunk);
    }

    function loadWithUri(string memory uri, uint256 chunkIndex) public view returns (bytes memory, int256) {
        // uri: bfs://chainId/contractAddress/address/filename
        bytes memory uriBytes = bytes(uri);
        bytes memory expectedPrefix = bytes(string.concat("bfs://", Strings.toString(block.chainid), "/"));
        uint256 prefixLen = expectedPrefix.length;
        if (uriBytes.length < prefixLen + 86) revert InvalidURI();
        if (uriBytes[prefixLen + 42] != bytes1('/')) revert InvalidURI();
        if (uriBytes[prefixLen + 86 - 1] != bytes1('/')) revert InvalidURI();
        for (uint i = 0; i < prefixLen; i++) {
            if (uriBytes[i] != expectedPrefix[i]) revert InvalidURI();
        }

        bytes memory contractAddressBytes = new bytes(42);
        for (uint i = 0; i < 42; i++) {
            contractAddressBytes[i] = uriBytes[i + prefixLen];
        }
        address contractAddress = addressFromHexString(string(contractAddressBytes));


        bytes memory addressBytes = new bytes(42);
        for (uint i = 0; i < 42; i++) {
            addressBytes[i] = uriBytes[i + prefixLen + 42 + 1];
        }
        address addr = addressFromHexString(string(addressBytes));

        bytes memory filenameBytes = new bytes(uriBytes.length - (prefixLen + 86));
        for (uint i = 0; i < uriBytes.length - (prefixLen + 86); i++) {
            filenameBytes[i] = uriBytes[i + (prefixLen + 86)];
        }
        string memory filename = string(filenameBytes);

        bytes memory callData = abi.encodeWithSignature("load(address,string,uint256)", addr, filename, chunkIndex);
        (bool success, bytes memory returnData) = contractAddress.staticcall(callData);
        if (!success) revert InvalidBfsResult();
        (bytes memory data, int256 nextChunk) = abi.decode(returnData, (bytes, int256));
        return (data, nextChunk);
    }

    function loadFile(address addr, string memory filename) public view returns (bytes memory) {
        bytes memory data;
        bytes memory fullData = new bytes(0);

        uint256 maxInd = chunks[addr][filename];
        for (uint256 i = 0; i <= maxInd; i++) {
            data = dataStorage[addr][filename][i];
            fullData = abi.encodePacked(fullData, data);
        }
        return fullData;
    }


    function loadFileWithUri(string memory uri) public view returns (bytes memory) {
        bytes memory uriBytes = bytes(uri);
        bytes memory expectedPrefix = bytes(string.concat("bfs://", Strings.toString(block.chainid), "/"));
        uint256 prefixLen = expectedPrefix.length;
        if (uriBytes.length < prefixLen + 86) revert InvalidURI();
        if (uriBytes[prefixLen + 42] != bytes1('/')) revert InvalidURI();
        if (uriBytes[prefixLen + 86 - 1] != bytes1('/')) revert InvalidURI();
        for (uint i = 0; i < prefixLen; i++) {
            if (uriBytes[i] != expectedPrefix[i]) revert InvalidURI();
        }

        bytes memory contractAddressBytes = new bytes(42);
        for (uint i = 0; i < 42; i++) {
            contractAddressBytes[i] = uriBytes[i + prefixLen];
        }
        address contractAddress = addressFromHexString(string(contractAddressBytes));


        bytes memory addressBytes = new bytes(42);
        for (uint i = 0; i < 42; i++) {
            addressBytes[i] = uriBytes[i + prefixLen + 42 + 1];
        }
        address addr = addressFromHexString(string(addressBytes));

        bytes memory filenameBytes = new bytes(uriBytes.length - (prefixLen + 86));
        for (uint i = 0; i < uriBytes.length - (prefixLen + 86); i++) {
            filenameBytes[i] = uriBytes[i + (prefixLen + 86)];
        }
        string memory filename = string(filenameBytes);

        int256 chunkIndex = 0;
        bytes memory data;
        bytes memory fullData = new bytes(0);

        while (chunkIndex >= 0) {
            bytes memory callData = abi.encodeWithSignature("load(address,string,uint256)", addr, filename, uint256(chunkIndex));
            (bool success, bytes memory returnData) = contractAddress.staticcall(callData);
            if (!success) revert InvalidBfsResult();

            (data, chunkIndex) = abi.decode(returnData, (bytes, int256));
            fullData = abi.encodePacked(fullData, data);
        }
        return fullData;
    }

    function count(address addr, string memory filename) public view returns (uint256) {
        return chunks[addr][filename];
    }

    function getId(address addr, string memory filename) public view returns (uint256) {
        return bfsId[addr][filename];
    }

    function getAllAddresses() public view returns (address[] memory) {
        return addresses.values();
    }

    function getAllFilenames(address addr) public view returns (string[] memory) {
        return filenames[addr];
    }

    function addressFromHexString(string memory hexStr) internal pure returns (address) {
        bytes memory bytesString = bytes(hexStr);
        uint160 addr;
        for (uint i = 2; i < bytesString.length; i++) {
            uint160 c = uint160(uint8(bytesString[i]));
            if (c >= 48 && c <= 57) {
                addr = addr * 16 + (c - 48);
            }
            if (c >= 65 && c <= 70) {
                addr = addr * 16 + (c - 55);
            }
            if (c >= 97 && c <= 102) {
                addr = addr * 16 + (c - 87);
            }
        }
        return address(bytes20(addr));
    }
}