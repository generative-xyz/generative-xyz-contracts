pragma solidity ^0.8.0;

library Marketplace {
    event ListingToken(bytes32 indexed offeringId, address indexed hostContract, address indexed offerer, uint tokenId, uint price);
    event PurchaseToken(bytes32 indexed offeringId, address indexed buyer);
    event CancelListing(bytes32 indexed offeringId, address indexed offerer);

    struct Benefit {
        uint256 benefitPercentCreator;// TODO
        uint256 benefitCreator;// TODO
        uint256 benefitPercentOperator;
        uint256 benefitOperator;
    }

    struct ListingTokenData {
        address offerer;
        address hostContract; // erc-721 collection address
        uint tokenId;
        uint price;
        bool closed;
        address erc20Token;
    }

    struct PurchaseTokenData {
        address buyer;
        uint price;
        uint originPrice;
        uint256 balanceBuyer;
        uint256 approvalToken;
        address erc20Token;
    }

    struct MultiBuyOffering {
        address _buyer;
        uint256 _budget;
        address _erc20Token;
        uint256 _durationTime;
    }
}
