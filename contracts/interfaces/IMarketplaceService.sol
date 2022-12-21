pragma solidity ^0.8.0;

interface IMarketplaceService {
    function listToken(address _hostContract, uint _tokenId, address _erc20Token, uint _price) external virtual returns (bytes32);

    function purchaseToken(bytes32 _offeringId) external virtual payable;
}
