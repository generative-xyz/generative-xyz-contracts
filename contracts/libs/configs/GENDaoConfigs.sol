pragma solidity ^0.8.0;

library GENDaoConfigs {
    string public constant OPERATOR_TREASURE_ADDR = "MINT_NFT_OPERATOR_TREASURE_ADDR";
    string public constant GEN_TOKEN = "GEN_TOKEN";// param key for GENToken address, marketplace get this address and set PoA for GENToken artist
    string public constant TEAM_VESTING = "TEAM_VESTING";
    uint256 public constant oneYearBlocks = 6575 * 365;
}
