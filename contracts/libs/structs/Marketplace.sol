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
        address _seller;
        address _collectionContract; // erc-721 collection address
        uint _tokenId;
        uint _price;
        bool _closed;
        address _erc20Token;
        uint256 _durationTime;
    }

    struct PurchaseTokenData {
        address _buyer;
        uint _price;
        uint _originPrice;
        uint256 _balanceBuyer;
        uint256 _approvalToken;
        address _erc20Token;
    }

    struct MakeOfferData {
        address _offerErc20Token; // only support WETH
        uint256 _offerPrice;
        address _buyer;
        uint256 _durationTime;
    }
}
