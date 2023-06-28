pragma solidity ^0.8.0;

interface IBaseERC721OwnerSeedUpgradeable {
    function getStatus() external view returns (bool);

    function initialize(
        string memory name,
        string memory symbol
    ) external;
}
