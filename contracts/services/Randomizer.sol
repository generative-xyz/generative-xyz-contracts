pragma solidity ^0.8.0;

import "../interfaces/IRandomizer.sol";

contract Randomizer is IRandomizer {
    
    function generateTokenHash(uint256 tokenId) internal virtual returns (bytes32 tokenHash) {
        uint256 time = block.timestamp;
        tokenHash = keccak256(
            abi.encodePacked(
                tokenId,
                block.number,
                blockhash(block.number - 1)
            )
        );
    }
}
