// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {File} from "./IFileStore.sol";

interface IAgent {
    // --- Enums ---
    enum FileType {
        LIBRARY,
        MAIN_SCRIPT
    }

    // --- Structs ---
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

    // --- Events ---
    event CodePointerCreated(
        uint256 indexed agentId,
        uint256 indexed version,
        uint256 indexed pIndex,
        CodePointer newPointer
    );

    // --- Errors ---
    error Unauthenticated();
    error DigestAlreadyUsed();
    error InvalidData();
    error InvalidDependency();
    error InvalidVersion();

    // --- State-Changing Functions ---
    function publishAgentCode(
        uint256 agentId,
        string calldata codeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents
    ) external returns (uint16 version);

    function publishAgentCodeWithSignature(
        uint256 agentId,
        string calldata codeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents,
        bytes calldata signature
    ) external returns (uint16 version);

    function updateAgentName(uint256 agentId, string calldata name) external;

    function updateAgentAbility(
        uint256 agentId,
        string calldata ability
    ) external;

    // --- View functions ---
    function getDepsAgents(
        uint256 agentId,
        uint16 version
    ) external view returns (uint256[] memory);

    function getAgentCode(
        uint256 agentId,
        uint16 version
    ) external view returns (string memory code);

    function getCodeLanguage(
        uint256 agentId
    ) external view returns (string memory);

    function getCurrentVersion(uint256 agentId) external view returns (uint16);

    function getAgentName(
        uint256 agentId
    ) external view returns (string memory);

    function getAgentAbility(
        uint256 agentId
    ) external view returns (string memory);
}
