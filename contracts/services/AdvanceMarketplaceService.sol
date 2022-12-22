pragma solidity ^0.8.0;

import "./SimpleMarketplaceService.sol";

contract AdvanceMarketplaceService is SimpleMarketplaceService {

    mapping(address => mapping(uint256 => Marketplace.ListingTokenData[])) public _listingTokenDataMapping;

    mapping(address => mapping(uint256 => Marketplace.MakeOfferData[])) public _makeOfferDataMapping;

    function initialize(address admin, address parameterControl) initializer override public {
        super.initialize(admin, parameterControl);
    }

    function listToken(Marketplace.ListingTokenData memory listingData) external override returns (bytes32) {
        bytes32 offerId = _listToken(listingData);
        Marketplace.ListingTokenData storage data = _listingTokens[offerId];
        _listingTokenDataMapping[listingData._collectionContract][listingData._tokenId].push(data);
        return offerId;
    }

    function makeOffer(Marketplace.MakeOfferData memory makeOfferData) external override returns (bytes32) {
        bytes32 offerId = _makeOffer(makeOfferData);
        Marketplace.MakeOfferData storage data = _makeOfferTokens[offerId];
        _makeOfferDataMapping[data._collectionContract][data._tokenId].push(data);
        return offerId;
    }
}
