pragma solidity ^0.8.0;

import "../libs/structs/Auction.sol";

interface IAuction {
    event AuctionCreated(uint256 indexed tokenId, uint256 startTime, uint256 endTime, address sender, bytes32 auctionId, AuctionHouse.Auction auction);

    event AuctionBid(uint256 indexed tokenId, address sender, uint256 value, bool extended, AuctionHouse.Auction auction);

    event AuctionClaimBid(uint256 indexed tokenId, address sender, uint256 value, bytes32 auctionId);

    event AuctionExtended(uint256 indexed tokenId, uint256 endTime, AuctionHouse.Auction auction);

    event AuctionSettled(uint256 indexed tokenId, address winner, uint256 amount, AuctionHouse.Auction auction);

    event AuctionClosed(uint256 indexed tokenId);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    function settleAuction(uint256 tokenId) external;

    function createBid(uint256 tokenId, uint256 amount) external;

}
