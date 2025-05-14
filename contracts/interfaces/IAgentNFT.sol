// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IMintableAgent {
    function isUnlockedAgent(uint256 _agentId) external view returns (bool);

    function getAgentRating(uint256 _agentId) external view returns (uint256, uint256);

    function getAgentRarity(uint256 _agentId) external view returns (uint256);
}