// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {File} from "./IFileStore.sol";

interface IAgent {
    enum FileType {
        LIBRARY,
        MAIN_SCRIPT
    }

    struct CodePointer {
        address retrieveAddress;
        FileType fileType;
        string fileName;
    }

    struct SignData {
        CodePointer[] pointers;
        address[] depsAgents;
        uint16 currentVersion;
    }

    event CodePointerCreated(
        uint256 indexed version,
        uint256 indexed pIndex,
        CodePointer newPointer
    );

    error Unauthenticated();
    error DigestAlreadyUsed();
    error InvalidData();
    error ZeroAddress();
    error InvalidVersion();

    function publishAgentCode(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents
    ) external returns (uint16 version);

    function publishAgentCodeWithSignature(
        uint256 tokenId,
        CodePointer[] calldata pointers,
        address[] calldata depsAgents,
        bytes calldata signature
    ) external returns (uint16 version);

    function getDepsAgents(
        uint256 tokenId,
        uint16 version
    ) external view returns (address[] memory);

    function getAgentCode(
        uint256 tokenId,
        uint16 version
    ) external view returns (string memory code);

    function getCodeLanguage(
        uint256 tokenId
    ) external view returns (string memory);

    function getCurrentVersion(uint256 tokenId) external view returns (uint16);

    function getAgentPersonality(
        uint256 tokenId
    ) external view returns (string memory);

    function getAgentAbility(
        uint256 tokenId
    ) external view returns (string memory);
}
