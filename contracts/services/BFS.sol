// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

    error FileExists();

contract BFS {
    using Counters for Counters.Counter;
    Counters.Counter private idCounter;
    mapping(address => mapping(string => mapping(uint256 => bytes))) public dataStorage;
    mapping(address => mapping(string => uint256)) public chunks; // max chunk index
    mapping(address => mapping(string => uint256)) public bfsId;

    constructor () {
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
    }

    function load(address addr, string memory filename, uint256 chunkIndex) public view returns (bytes memory, int256) {
        uint256 temp = chunkIndex + 1;
        int256 nextChunk = (temp > chunks[addr][filename]) ? - 1 : int256(temp);
        return (dataStorage[addr][filename][chunkIndex], nextChunk);
    }

    function count(address addr, string memory filename) public view returns (uint256) {
        return chunks[addr][filename];
    }

    function getId(address addr, string memory filename) public view returns (uint256) {
        return bfsId[addr][filename];
    }
}