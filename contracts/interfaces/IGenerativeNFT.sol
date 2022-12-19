// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../libs/structs/NFTProject.sol";
import "./IBaseERC721OwnerSeed.sol";

interface IGenerativeNFT is IBaseERC721OwnerSeed {
    function init(NFTProject.ProjectMinting memory project, address admin, address paramsAddr, address randomizer, address projectDataContextAddr, address[] memory reserves, bool disable, uint256 royalty) external;

    function setStatus(bool enable) external;
}