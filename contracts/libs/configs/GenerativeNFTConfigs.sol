pragma solidity ^0.8.0;

library GenerativeNFTConfigs {
    // percentage royalty for minting 
    string public constant MINT_NFT_OPERATOR_FEE = "MINT_NFT_OPERATOR_FEE"; // default 500 ~ 5%
    string public constant MINT_NFT_OPERATOR_TREASURE_ADDR = "MINT_NFT_OPERATOR_TREASURE_ADDR";
    uint256 public constant PROJECT_PADDING = 1000000;

    // royalty for second sale
    string public constant ROYALTY_FIN_ADDRESS = "ROYALTY_FIN_ADDRESS"; // [contract address] receive royalty of second sale[default: DEFAULT_ROYALTY_FIN_PERCENT] and split to project's owner
    string public constant DEFAULT_ROYALTY_FIN_PERCENT = "DEFAULT_ROYALTY_FIN_PERCENT";// default 500 ~ 5%
}
