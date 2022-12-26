pragma solidity ^0.8.0;

library Royalty {
    event SetProxyRoyaltySecondSale(address indexed addr, bool indexed approve);
    event PaymentReceived(address indexed from, uint256 indexed amount);
    event WithdrawRoyalty(address indexed account, uint256 indexed projectId, address indexed erc20Addr);
    event Withdraw(address indexed _admin, address indexed erc20Addr);
    event SetRoyaltySecondSale(address sender, uint256 tokenId, address erc20Addr, uint256 amount);
    event SetRoyaltySecondSaleFail(address sender, uint256 tokenId, address erc20Addr, uint256 amount);

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
