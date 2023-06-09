pragma solidity ^0.8.0;

interface IAuction {
    event AuctionCreated(uint256 indexed nounId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed nounId, address sender, uint256 value, bool extended);

    event AuctionExtended(uint256 indexed nounId, uint256 endTime);

    event AuctionSettled(uint256 indexed nounId, address winner, uint256 amount);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction(uint256 tokenId) external;

    function createBid(uint256 tokenId, uint256 amount) external payable;

    /*function settleCurrentAndCreateNewAuction(uint256 tokenId) external;

    function pause() external;

    function unpause() external;

    function setTimeBuffer(tokenId uint256, uint256 timeBuffer) external;

    function setReservePrice(tokenId uint256, uint256 reservePrice) external;

    function setMinBidIncrementPercentage(tokenId uint256, uint8 minBidIncrementPercentage) external;*/

}
