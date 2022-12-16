pragma solidity ^0.8.0;

library Royalty {
    struct RoyaltyInfo {
        address recipient;
        uint24 amount;
        bool isValue;
    }

    struct CollaborationShared {
        address[] _collaborators;
        uint256[] _shared;
    }
}
