pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IGENToken is IVotesUpgradeable, IERC20Upgradeable {
    event ClaimToken(address to, uint256 amount, uint256 primary, uint256, uint256 second);
    event NotSupportProjectIndex(address genNFT);
    event NotSupportProjectAddress(address genNFT);

    function setPoASecondSale(address collectionAddr, uint256 tokenId, address erc20Addr, uint256 amount) external;
}
