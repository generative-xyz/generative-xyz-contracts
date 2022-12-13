pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IGenerativeProject is IERC721Upgradeable {
    function completeProject(uint256 projectId) external;
}