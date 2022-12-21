pragma solidity ^0.8.0;

library Marketplace {
    event ListingToken(bytes32 indexed offeringId, address indexed hostContract, address indexed offerer, uint tokenId, uint price);
    event PurchaseToken(bytes32 indexed offeringId, address indexed buyer);
    event CancelListing(bytes32 indexed offeringId, address indexed offerer);

    struct Benefit {
        uint256 benefitPercentCreator;
        uint256 benefitCreator;
        uint256 benefitPercentOperator;
        uint256 benefitOperator;
        uint256 discountRoveToken;
    }

    struct Offering {
        address offerer;
        address hostContract;
        uint tokenId;
        uint price;
        bool closed;
        address erc20Token;
    }

    struct CloseOfferingData {
        address buyer;
        uint price;
        uint originPrice;
        uint256 balanceBuyer;
        uint256 approvalToken;
        address erc20Token;
    }
}
