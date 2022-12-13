// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../libs/structs/NFTProject.sol";

interface IGenerativeNFT {
    function init(NFTProject.ProjectData memory project, address admin, address randomizer, address[] memory reserves) external;
}