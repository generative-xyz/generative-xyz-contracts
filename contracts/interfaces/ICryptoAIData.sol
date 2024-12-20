// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ICryptoAIData {
    function tokenURI(uint256 tokenId) external view returns (string memory result);

    function mintAgent(uint256 tokenId) external;

    function unlockRenderAgent(uint256 tokenId) external;
}