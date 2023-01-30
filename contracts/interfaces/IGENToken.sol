pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IGENToken is IVotesUpgradeable, IERC20Upgradeable {
    event ClaimToken(address to, uint256 amount);
    event NotSupportProjectIndex(address genNFT);
}
