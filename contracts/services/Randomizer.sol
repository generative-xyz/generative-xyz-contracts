pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/IRandomizer.sol";

contract Randomizer is OwnableUpgradeable, IRandomizer {

    function initialize() initializer public {
        __Ownable_init();
    }

    function generateTokenHash(uint256 tokenId) external virtual override returns (bytes32 tokenHash) {
        tokenHash = keccak256(
            abi.encodePacked(
                tokenId,
                block.number,
                blockhash(block.number - 1),
                block.timestamp
            )
        );
    }
}
