pragma solidity ^0.8.0;

interface IGenerativeProjectData {
    function tokenURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result);
}
