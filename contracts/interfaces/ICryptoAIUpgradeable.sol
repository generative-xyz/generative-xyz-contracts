// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ICryptoAIUpgradeable {
    // Unlocks a token with the given tokenId, dna, and traits. Requires a payment.
    function unlock(
        uint256 tokenId,
        uint256 dna,
        uint256[5] memory traits
    ) external payable;

    // Returns the address of the CryptoAI data contract.
    function cryptoAiDataAddr() external view returns (address);
}
