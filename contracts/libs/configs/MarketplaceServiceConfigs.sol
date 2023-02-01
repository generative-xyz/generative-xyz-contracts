pragma solidity ^0.8.0;

library MarketplaceServiceConfigs {
    uint256 public constant DEFAULT_MARKETPLACE_BENEFIT_PERCENT = 250; // default marketplace get 2.5% trading
    string public constant MARKETPLACE_BENEFIT_PERCENT = "MARKETPLACE_BENEFIT_PERCENT";// param key for marketplace percent trading
}
