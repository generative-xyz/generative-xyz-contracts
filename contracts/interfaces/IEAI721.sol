// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEAI721 {

    // =============================================
    // IEAI721AgentAbility
    // =============================================

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

  /**
     * @dev Updates the name of a specific agent.
     * @param agentId The unique identifier of the agent.
     * @param name The new name to assign to the agent.
     */
    function setAgentName(uint256 agentId, string calldata name) external;

    /**
     * @dev Updates the ability of a specific agent.
     * @param agentId The unique identifier of the agent.
     * @param ability The new ability to assign to the agent.
     */
    function setAgentAbility(uint256 agentId, string calldata ability) external;

    /**
     * @dev Retrieves the name of a specific agent.
     * @param agentId The unique identifier of the agent.
     * @return The name of the agent.
     */
    function agentName(uint256 agentId) external view returns (string memory);

    /**
     * @dev Retrieves the ability of a specific agent.
     * @param agentId The unique identifier of the agent.
     * @return The ability of the agent.
     */
    function agentAbility(uint256 agentId) external view returns (string memory);

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
     * @dev Retrieves the dependent agent IDs for a specific agent and version.
     * @param agentId The unique identifier of the agent.
     * @param version The version number of the agent's code.
     * @return An array of dependent agent IDs.
     */
    function depsAgents(uint256 agentId, uint16 version) external view returns (uint256[] memory);

    /**
     * @dev Retrieves the code of a specific agent for a given version.
     * @param agentId The unique identifier of the agent.
     * @param version The version number of the agent's code.
     * @return code The code of the agent.
     */
    function agentCode(uint256 agentId, uint16 version) external view returns (string memory code);

    /**
     * @dev Retrieves the current version of a specific agent's code.
     * @param agentId The unique identifier of the agent.
     * @return The current version number of the agent's code.
     */
    function currentVersion(uint256 agentId) external view returns (uint16);

    /**
     * @dev Retrieves the programming language of a specific agent's code.
     * @param agentId The unique identifier of the agent.
     * @return The programming language of the agent's code.
     */
    function codeLanguage(uint256 agentId) external view returns (string memory);

    /**
     * @dev Generates a hash to sign for publishing agent code.
     * @param agentId The unique identifier of the agent.
     * @param pointers An array of code pointers for the agent.
     * @param depsAgents An array of dependent agent IDs.
     * @return The hash to be signed.
     */
    function hashToSign(
        uint256 agentId,
        CodePointer[] calldata pointers,
        uint256[] calldata depsAgents
    ) external view returns (bytes32);

    // =============================================
    // IEAI721Art
    // =============================================

    /**
     * @dev Mints a new token to the specified address with the given dna, traits, agent name, and agent ability.
     * @param to The address to which the new token will be minted.
     * @param dna The DNA value for the new token.
     * @param traits An array of traits for the new token.
     * @param agentName The name of the agent associated with the token.
     * @param agentAbility The ability of the agent associated with the token.
     */
    function mint(
        address to, 
        uint256 dna, 
        uint256[5] memory traits, 
        string calldata agentName, 
        string calldata agentAbility
    ) external;

    /**
     * @dev Retrieves the URI for a specific token.
     * @param tokenId The unique identifier of the token.
     * @return The URI string of the token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    // =============================================
    // IEAI721Monetization
    // =============================================

    /**
     * @dev Retrieves the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @return The subscription fee associated with the given agent.
     */
    function subscriptionFee(uint256 agentId) external view returns (uint256);

    /**
     * @dev The AI token associated with a specific agent.
     * @param agentId The ID of the agent.
     * @return The address of the AI token for the given agent.
     */
    function aiToken(uint256 agentId) external view returns (address);

    /**
     * @dev Sets the subscription fee for a specific agent.
     * @param agentId The ID of the agent.
     * @param fee The subscription fee to be set for the agent.
     */
    function setSubscriptionFee(uint256 agentId, uint256 fee) external;

    /**
     * @dev Updates the AI token address for a specific agent.
     * @param agentId The ID of the agent.
     * @param newAIToken The new AI token address to be set for the agent.
     */
    function setAITokenAddress(uint256 agentId, address newAIToken) external;
}