pragma solidity ^0.8.0;

import "../libs/structs/Marketplace.sol";

interface IMarketplaceService {
    function listToken(Marketplace.ListingTokenData memory listingData) external virtual returns (bytes32);

    function purchaseToken(bytes32 _offeringId) external virtual payable;

    function cancelListing(bytes32 _offeringId) external virtual;
}
