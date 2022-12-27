pragma solidity ^0.8.0;

library RoyaltyFinanceSecondSaleConfigs {
    uint256 public constant DEFAULT_OWNER_ROYALTY_SECOND_SALE = 9000;// default 90%
    string public constant OWNER_ROYALTY_SECOND_SALE = "OWNER_ROYALTY_SECOND_SALE"; // key for get param control for owner royalty percent on second sale
}
