// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721Art {

    /**
     * @dev Mints a new token to the specified address with the given dna, traits, agent name, and agent ability.
     * @param to The address to which the new token will be minted.
     * @param dna The DNA value for the new token.
     * @param traits An array of traits for the new token.
     * @param agentName The name of the agent associated with the token.
     * @param agentAbility The ability of the agent associated with the token.
     */
    function mint(
        address to, 
        uint256 dna, 
        uint256[5] memory traits, 
        string calldata agentName, 
        string calldata agentAbility
    ) external;

    /**
     * @dev Retrieves the URI for a specific token.
     * @param tokenId The unique identifier of the token.
     * @return The URI string of the token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
