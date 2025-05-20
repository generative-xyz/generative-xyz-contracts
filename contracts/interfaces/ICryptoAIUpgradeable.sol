// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICryptoAIUpgradeable {
    // Unlocks a token with the given tokenId, dna, and traits. Requires a payment.
    function unlock(
        uint256 tokenId,
        uint256 dna,
        uint256[5] memory traits
    ) external payable;

    // Sets the subscription fee for a specific token identified by tokenId.
    function setSubscriptionFee(uint256 tokenId, uint256 fee) external;

    // Returns the subscription fee for a specific token identified by tokenId.
    function subscriptionFee(uint256 tokenId) external view returns (uint256);

    // Sets the token address for a specific token identified by tokenId.
    function setTokenAddress(uint256 tokenId, address tokenAddress) external;

    // Returns the token address for a specific token identified by tokenId.
    function tokenAddress(uint256 tokenId) external view returns (address);

    // Returns the address of the CryptoAI data contract.
    function cryptoAiDataAddr() external view returns (address);
}
