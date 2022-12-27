pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../libs/structs/NFTProject.sol";

interface IGenerativeProject is IERC721Upgradeable {
    function projectDetails(uint256 _projectId) external view returns (NFTProject.Project memory project);

    function completeProject(uint256 projectId) external;
}