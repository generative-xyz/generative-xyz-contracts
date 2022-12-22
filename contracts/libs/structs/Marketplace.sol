pragma solidity ^0.8.0;

library Marketplace {
    event ListingToken(bytes32 indexed offeringId, address indexed hostContract, address indexed offerer, uint tokenId, uint price);
    event PurchaseToken(bytes32 indexed offeringId, address indexed buyer);
    event CancelListing(bytes32 indexed offeringId, address indexed offerer);
    event CancelMakeOffer(bytes32 indexed offeringId, address indexed offerer);
    event AcceptMakeOffer(bytes32 indexed offeringId, address indexed seller, address indexed buyer);

    struct Benefit {
        uint256 benefitPercentCreator;// TODO
        uint256 benefitCreator;// TODO
        uint256 benefitPercentOperator;
        uint256 benefitOperator;
    }

    struct ListingTokenData {
        address _collectionContract; // erc-721 collection address
        uint256 _tokenId;
        address _seller;
        uint _price;
        address _erc20Token;
        bool _closed;
        uint256 _durationTime;
    }

    struct PurchaseTokenData {
        address _buyer;
        uint256 _price;
        uint256 _originPrice;
        uint256 _balanceBuyer;
        uint256 _approvalToken;
        address _erc20Token;
    }

    struct MakeOfferData {
        address _collectionContract; // erc-721 collection address
        uint256 _tokenId;
        address _buyer;
        address _erc20Token; // only support WETH
        uint256 _price;
        bool _closed;
        uint256 _durationTime;
    }
}
