pragma solidity ^0.8.0;

interface IAuction {
    event AuctionCreated(uint256 indexed tokenId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed tokenId, address sender, uint256 value, bool extended);

    event AuctionClaimBid(uint256 indexed tokenId, address sender, uint256 value);

    event AuctionExtended(uint256 indexed tokenId, uint256 endTime);

    event AuctionSettled(uint256 indexed tokenId, address winner, uint256 amount);

    event AuctionClosed(uint256 indexed tokenId);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction(uint256 tokenId) external;

    function createBid(uint256 tokenId, uint256 amount) external payable;

    function claimBid(uint256 tokenId) external;

}
