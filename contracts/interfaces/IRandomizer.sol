pragma solidity ^0.8.0;

interface IRandomizer {
    function generateTokenHash(uint256 tokenId) external returns (bytes32 tokenHash);
}
