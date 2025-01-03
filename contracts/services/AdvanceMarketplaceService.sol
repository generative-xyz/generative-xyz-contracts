pragma solidity ^0.8.0;

import "./SimpleMarketplaceService.sol";

contract AdvanceMarketplaceService is SimpleMarketplaceService {

    // collection => tokenId => offer[]
    mapping(address => mapping(uint256 => Marketplace.ListingTokenData[])) public _listingTokenDataMapping;
    // collection => tokenId[]
    mapping(address => uint256[]) public _listingTokenIds;
    // collection => tokenId => offer[]
    mapping(address => mapping(uint256 => Marketplace.MakeOfferData[])) public _makeOfferDataMapping;
    // collection => tokenId[]
    mapping(address => uint256[]) public _makeOfferTokenIds;

    mapping(address => bool) public _allowableERC20MakeOffer;
    mapping(address => bool) public _allowableERC20MakeListToken;

    function initialize(address admin, address parameterControl) initializer override public {
        super.initialize(admin, parameterControl);
    }

    function setApproveERC20MakeOffer(address erc20, bool allow) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);

        _allowableERC20MakeOffer[erc20] = allow;
    }

    function setApproveERC20ListToken(address erc20, bool allow) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);

        _allowableERC20MakeListToken[erc20] = allow;
    }

    function listToken(Marketplace.ListingTokenData memory listingData) external override returns (bytes32) {
        require(_allowableERC20MakeListToken[listingData._erc20Token], Errors.ERC_20_NOT_ALLOW);
        bytes32 offerId = _listToken(listingData);
        Marketplace.ListingTokenData storage data = _listingTokens[offerId];
        _listingTokenDataMapping[data._collectionContract][data._tokenId].push(data);
        _listingTokenIds[data._collectionContract].push(data._tokenId);
        return offerId;
    }

    function makeOffer(Marketplace.MakeOfferData memory makeOfferData) external override returns (bytes32) {
        require(_allowableERC20MakeOffer[makeOfferData._erc20Token], Errors.ERC_20_NOT_ALLOW);
        bytes32 offerId = _makeOffer(makeOfferData);
        Marketplace.MakeOfferData storage data = _makeOfferTokens[offerId];
        _makeOfferDataMapping[data._collectionContract][data._tokenId].push(data);
        _makeOfferTokenIds[data._collectionContract].push(data._tokenId);
        return offerId;
    }

    function sweep(bytes32[] memory offers) external payable nonReentrant() {
        require(offers.length <= 100);
        bytes32[] memory result = new bytes32[](offers.length);
        for (uint256 i; i < offers.length; i++) {
            if (!_listingTokens[offers[i]]._closed) {
                _purchaseToken(offers[i]);
                result[i] = offers[i];
            }
            if (gasleft() < 200000) {break;}
        }
        emit Marketplace.Sweep(result);
    }

    function makeOfferCollection(Marketplace.MakeOfferCollectionData memory makeOfferCollectionData) external returns (bytes32[] memory result) {
        require(_allowableERC20MakeOffer[makeOfferCollectionData._erc20Token], Errors.ERC_20_NOT_ALLOW);
        result = new bytes32[](makeOfferCollectionData._tokenIds.length);
        for (uint256 i; i < makeOfferCollectionData._tokenIds.length; i++) {
            Marketplace.MakeOfferData memory makeOfferData = Marketplace.MakeOfferData(
                makeOfferCollectionData._collectionContract,
                makeOfferCollectionData._tokenIds[i],
                msg.sender,
                makeOfferCollectionData._erc20Token,
                makeOfferCollectionData._price / makeOfferCollectionData._tokenIds.length,
                false,
                makeOfferCollectionData._durationTime
            );
            bytes32 offerId = _makeOffer(makeOfferData);
            Marketplace.MakeOfferData storage data = _makeOfferTokens[offerId];
            _makeOfferDataMapping[data._collectionContract][data._tokenId].push(data);
            _makeOfferTokenIds[data._collectionContract].push(data._tokenId);
            result[i] = offerId;
            if (gasleft() < 200000) {break;}
        }
        emit Marketplace.MakeCollectionOffer(result);
    }

    function updateListingPrice(bytes32 offerId, uint256 price) external {
        require(price > 0 && 1 == 0);
        _listingTokens[offerId]._price = price;
        emit Marketplace.UpdateListingPrice(offerId, price);
    }

    function updateMakeOfferPrice(bytes32 offerId, uint256 price) external {
        require(price > 0 && 1 == 0);
        _makeOfferTokens[offerId]._price = price;
        emit Marketplace.UpdateMakeOfferPrice(offerId, price);
    }
}
