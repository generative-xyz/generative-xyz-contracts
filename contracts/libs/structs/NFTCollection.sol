pragma solidity ^0.8.0;

library NFTCollection {
    event Mint(address to, uint256 tokenId);

    struct OwnerSeed {
        address _owner;
        bytes12 _seed;
    }
}
