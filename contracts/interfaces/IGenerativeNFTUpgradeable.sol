// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../libs/structs/NFTProject.sol";
import "./IBaseERC721OwnerSeedUpgradeable.sol";

interface IGenerativeNFTUpgradeable is IBaseERC721OwnerSeedUpgradeable {
    function init(NFTProject.ProjectMinting memory project, address admin, address paramsAddr, address randomizer, address projectDataContextAddr, bool disable) external;

    function setStatus(bool enable) external;

    function updatePrice(uint256 price) external;

    function updatePriceAddress(address mintPriceAddress) external;

    function projectIndex() external view returns (uint24);

    function projectAddress() external view returns (address);
}