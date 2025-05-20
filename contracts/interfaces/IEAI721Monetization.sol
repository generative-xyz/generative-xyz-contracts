// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721Monetization {
    /**
     * @dev Retrieves the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @return The subscription fee associated with the given agent.
     */
    function subscriptionFee(uint256 agentId) external view returns (uint256);

    /**
     * @dev The AI token associated with a specific agent.
     * @param agentId The ID of the agent.
     * @return The address of the AI token for the given agent.
     */
    function aiToken(uint256 agentId) external view returns (address);

    /**
     * @dev Sets the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @param fee The subscription fee to be set for the agent.
     */
    function setSubscriptionFee(uint256 agentId, uint256 fee) external;

    /**
     * @dev Updates the AI token address for a specific agent.
     * @param agentId The ID of the agent.
     * @param newAIToken The new AI token address to be set for the agent.
     */
    function setAITokenAddress(uint256 agentId, address newAIToken) external;
}