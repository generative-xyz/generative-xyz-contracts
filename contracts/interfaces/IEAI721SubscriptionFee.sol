// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721SubscriptionFee {
    /**
     * @dev Retrieves the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @return The subscription fee associated with the given agent.
     */
    function subscriptionFee(uint256 agentId) external view returns (uint256);

    /**
     * @dev Sets the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @param fee The subscription fee to be set for the agent.
     */
    function setSubscriptionFee(uint256 agentId, uint256 fee) external;
}