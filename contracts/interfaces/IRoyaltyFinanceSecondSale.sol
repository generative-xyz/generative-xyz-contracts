pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface IRoyaltyFinanceSecondSale is IERC165Upgradeable {
    function setRoyaltySecondSale(uint256 tokenId, address erc20Addr, uint256 amount) external;
}
