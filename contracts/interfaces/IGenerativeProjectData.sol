pragma solidity ^0.8.0;

interface IGenerativeProjectData {
    function tokenBaseURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result);

    function tokenURI(uint256 projectId, uint256 tokenId, bytes32 seed) external view returns (string memory result);

    function projectURI(uint256 projectId) external view returns (string memory result);
}
