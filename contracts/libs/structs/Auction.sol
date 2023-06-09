pragma solidity ^0.8.0;

library AuctionHouse {
    struct Auction {
        // ID for the Noun (ERC721 token ID)
        uint256 tokenId;
        // Address for erc20 token for bidding
        address erc20Token;
        // The current highest bid amount
        uint256 amount;
        // The time that the auction started
        uint256 startTime;
        // The time that the auction is scheduled to end
        uint256 endTime;
        // The address of the current highest bid
        address payable bidder;
        // Whether or not the auction has been settled
        bool settled;

        // The minimum amount of time left in an auction after a new bid is created
        uint256 timeBuffer;

        // The minimum price accepted in an auction
        uint256 reservePrice;

        // The minimum percentage difference between the last bid amount and the current bid
        uint256 minBidIncrementPercentage;
    }
}
