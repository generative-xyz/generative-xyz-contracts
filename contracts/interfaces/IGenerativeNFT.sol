// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "../libs/structs/NFTProject.sol";

interface IGenerativeNFT {
    function init(NFTProject.ProjectMinting memory project, address admin, address paramsAddr, address randomizer, address[] memory reserves) external;
}