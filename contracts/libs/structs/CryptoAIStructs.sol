pragma solidity ^0.8.0;

library CryptoAIStructs {

    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, string[] name, uint16[] traits, uint8[][] positions);
    event DNAVariantAdded(string itemType, string[] name, uint16[] traits, uint8[][] positions);

    struct PositionDetail {
        uint8 x;      // 0-24
        uint8 y;      // 0-24
        uint8 colorId; // Index into colors array
    }

    struct ItemDetail {
        string[] names;
        uint256[] rarities;  // 0-200
        uint256[] c_rarities;
        uint8[][] positions; // x,y,r,g,b stored sequentially
    }

    struct ItemDetailAdd {
        string ele_type;
        string[] names;
        uint16[] rarities;  // 0-200
        uint8[][] positions; // x,y,r,g,b stored sequentially
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
