pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface IRoyaltyFinanceSecondSale is IERC165Upgradeable {
    event PaymentReceived(address from, uint256 amount);
    
    function setRoyaltySecondSale(uint256 tokenId, address erc20Addr, uint256 amount) external;
}
