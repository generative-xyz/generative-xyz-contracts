// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEAI721AgentAbility {
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

    
    /**
    * @dev Updates the name of a specific agent.
    * @param agentId The unique identifier of the agent.
    * @param name The new name to assign to the agent.
    */
    function updateAgentName(uint256 agentId, string calldata name) external;

    /**
    * @dev Updates the ability of a specific agent.
    * @param agentId The unique identifier of the agent.
    * @param ability The new ability to assign to the agent.
    */
    function updateAgentAbility(uint256 agentId, string calldata ability) external;

    /**
    * @dev Retrieves the name of a specific agent.
    * @param agentId The unique identifier of the agent.
    * @return The name of the agent.
    */
    function getAgentName(uint256 agentId) external view returns (string memory);

    /**
    * @dev Retrieves the ability of a specific agent.
    * @param agentId The unique identifier of the agent.
    * @return The ability of the agent.
    */
    function getAgentAbility(uint256 agentId) external view returns (string memory);

    /**
    * @dev Publishes the code for a specific agent.
    * @param agentId The unique identifier of the agent.
    * @param codeLanguage The programming language of the code.
    * @param pointers An array of code pointers for the agent.
    * @param depsAgents An array of dependent agent IDs.
    * @return The version number of the published code.
    */
    function publishAgentCode(
        uint256 agentId,
        string calldata codeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents
    ) external returns (uint16);

    /**
    * @dev Publishes the code for a specific agent with a signature for verification.
    * @param agentId The unique identifier of the agent.
    * @param codeLanguage The programming language of the code.
    * @param pointers An array of code pointers for the agent.
    * @param depsAgents An array of dependent agent IDs.
    * @param signature A cryptographic signature for verification.
    * @return The version number of the published code.
    */
    function publishAgentCodeWithSignature(
        uint256 agentId,
        string calldata codeLanguage,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents,
        bytes calldata signature
    ) external returns (uint16);

    /**
    * @dev Retrieves the dependent agent IDs for a specific agent and version.
    * @param agentId The unique identifier of the agent.
    * @param version The version number of the agent's code.
    * @return An array of dependent agent IDs.
    */
    function getDepsAgents(uint256 agentId, uint16 version) external view returns (uint256[] memory);

    /**
    * @dev Retrieves the code of a specific agent for a given version.
    * @param agentId The unique identifier of the agent.
    * @param version The version number of the agent's code.
    * @return code The code of the agent.
    */
    function getAgentCode(uint256 agentId, uint16 version) external view returns (string memory code);

    /**
    * @dev Retrieves the current version of a specific agent's code.
    * @param agentId The unique identifier of the agent.
    * @return The current version number of the agent's code.
    */
    function getCurrentVersion(uint256 agentId) external view returns (uint16);

    /**
    * @dev Retrieves the programming language of a specific agent's code.
    * @param agentId The unique identifier of the agent.
    * @return The programming language of the agent's code.
    */
    function getCodeLanguage(uint256 agentId) external view returns (string memory);

    /**
    * @dev Generates a hash to sign for publishing agent code.
    * @param agentId The unique identifier of the agent.
    * @param pointers An array of code pointers for the agent.
    * @param depsAgents An array of dependent agent IDs.
    * @return The hash to be signed.
    */
    function getHashToSign(
        uint256 agentId,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents
    ) external view returns (bytes32);
}