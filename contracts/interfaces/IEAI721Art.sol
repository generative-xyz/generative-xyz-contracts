// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721Art {
    /**
     * @dev Unlocks a token with the specified tokenId, dna, and traits. Requires a payment.
     * @param tokenId The unique identifier of the token to unlock.
     * @param dna The DNA value associated with the token.
     * @param traits An array of 5 traits associated with the token.
     */
    function unlock(
        uint256 tokenId,
        uint256 dna,
        uint256[5] memory traits
    ) external payable;
     
    /**
     * @dev Returns the address of the CryptoAI data contract.
     * @return The address of the CryptoAI data contract.
     */
    function cryptoAiDataAddr() external view returns (address);

    /**
     * @dev Retrieves the URI for a specific token.
     * @param tokenId The unique identifier of the token.
     * @return The URI string of the token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
