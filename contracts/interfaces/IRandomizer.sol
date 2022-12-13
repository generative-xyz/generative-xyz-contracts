pragma solidity ^0.8.0;

interface IRandomizer {
    function generateTokenHash(uint256 tokenId) external virtual returns (bytes32 tokenHash);
}
