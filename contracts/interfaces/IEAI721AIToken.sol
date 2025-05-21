// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721AIToken {
    /**
     * @dev The AI token associated with a specific agent.
     * @param agentId The ID of the agent.
     * @return The address of the AI token for the given agent.
     */
    function aiToken(uint256 agentId) external view returns (address);

    /**
     * @dev Updates the AI token address for a specific agent.
     * @param agentId The ID of the agent.
     * @param newAIToken The new AI token address to be set for the agent.
     */
    function setAITokenAddress(uint256 agentId, address newAIToken) external;
}