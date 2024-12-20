pragma solidity ^0.8.0;

library CryptoAIStructs {
    struct PositionDetail {
        uint8 x;      // 0-24
        uint8 y;      // 0-24
        uint8 colorId; // Index into colors array
    }

    struct ItemDetail {
        string[] names;
        uint256[] rarities;
        uint256[] c_rarities;
        uint256[][] positions; // x,y, index of pallets stored sequentially
    }

    struct DNA_TYPE {
        string[] names;
        uint256[] rarities;
        uint256[] c_rarities;
    }

    struct Token {
        uint256 tokenID;
        uint256 weight;

        // condition 1
        // tokenID = 0: not minted
        // tokenID > 0: minted
        // condition 2
        // weight = 0: draw animation url
        // weight > 0: draw svg image -> completely

        uint256[5] traits; // name attribute[body, head, ....] -> index trait
        uint256 dna;
    }
}
