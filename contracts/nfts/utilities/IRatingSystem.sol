// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRatingSystem {
    // --- Constants ---
    function MAX_RATING() external view returns (uint8);
    function MIN_RATING() external view returns (uint8);

    // --- Events ---
    event Rated(
        address indexed user,
        uint8 stars,
        uint256 newTotalStarsSum,
        uint256 newTotalRatingCount
    );

    // --- State-Changing Functions ---
    function rateStar(uint256 agentId, uint8 stars) external;

    // --- View functions ---
    function getRatingScore(uint256 agentId) external view returns (uint256);
    function getRatingCount(uint256 agentId) external view returns (uint256);
}
