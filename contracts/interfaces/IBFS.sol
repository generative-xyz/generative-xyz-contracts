// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface for the contract
interface IBFS {
    event FileStored(address indexed addr, string filename, uint256 chunkIndex, uint256 indexed bfsId, string uri);

    function store(string memory filename, uint256 chunkIndex, bytes memory _data) external;

    function load(address addr, string memory filename, uint256 chunkIndex) external view returns (bytes memory, int256);

    function count(address addr, string memory filename) external view returns (uint256);

    function getId(address addr, string memory filename) external view returns (uint256);

    function filenames(address addr, uint256 i) external view returns (string memory);

    function getAllAddresses() external view returns (address[] memory);

    function getAllFilenames(address addr) external view returns (string[] memory);

    function loadWithUri(string memory uri, uint256 chunkIndex) external view returns (bytes memory, int256);
}