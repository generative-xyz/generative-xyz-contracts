pragma solidity ^0.8.0;

library Marketplace {
    event ListingToken(bytes32 indexed offeringId, Marketplace.ListingTokenData data);
    event PurchaseToken(bytes32 indexed offeringId, Marketplace.ListingTokenData data, address buyer);
    event CancelListing(bytes32 indexed offeringId, Marketplace.ListingTokenData data);

    event MakeOffer(bytes32 indexed offeringId, Marketplace.MakeOfferData data);
    event CancelMakeOffer(bytes32 indexed offeringId, Marketplace.MakeOfferData data);
    event AcceptMakeOffer(bytes32 indexed offeringId, Marketplace.MakeOfferData data, address buyer);

    event Sweep(bytes32[] result);
    event MakeCollectionOffer(bytes32[] result);

    event UpdateListingPrice(bytes32 indexed offeringId, uint256 indexed price);
    event UpdateMakeOfferPrice(bytes32 indexed offeringId, uint256 indexed price);

    event SetPoA(address genToken, address collectionAddr, uint256 tokenId, address erc20Addr, uint256 amount);
    event SetPoAFail(address genToken, address collectionAddr, uint256 tokenId, address erc20Addr, uint256 amount);

    struct Benefit {
        address _royaltyReceiver;// contract/address get royalty second sale
        uint256 _royalty;// royalty second sale
        uint256 _benefitPercentOperator;
        uint256 _benefitOperator;
    }

    struct ListingTokenData {
        address _collectionContract; // erc-721 collection address
        uint256 _tokenId;
        address _seller;
        address _erc20Token;
        uint _price;
        bool _closed;
        uint256 _durationTime;
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

    struct CloseData {
        address _buyer;
        address _seller;
        uint256 _price;
        uint256 _originPrice;
        uint256 _balanceBuyer;
        uint256 _approvalToken;
        address _erc20Token;
    }

    struct MakeOfferCollectionData {
        address _collectionContract; // erc-721 collection address
        uint256[] _tokenIds;
        address _buyer;
        address _erc20Token; // only support WETH
        uint256 _price;
        bool _closed;
        uint256 _durationTime;
    }
}
