// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {CryptoAIUpgradeable} from "./CryptoAIUpgradeable.sol";

/**
 * @dev Extension of {CryptoAIUpgradeable} that allows AI agent owner to set token address attach to the agent.
 */
abstract contract CryptoAITokenUpgradeable is Initializable, CryptoAIUpgradeable {

    mapping(uint256 => address) private _aiTokens;

    event AITokenSet(uint256 indexed agentId, address indexed aiToken);

    function __CryptoAITokenUpgradeable_init() internal onlyInitializing {
    }

    function __CryptoAITokenUpgradeable_init_unchained() internal onlyInitializing {
    }

    /**
     * @dev Set AI token address.
     */
    function setAITokenAddress(uint256 agentId, address aiToken) public virtual onlyAgentOwner(agentId){
        _aiTokens[agentId] = aiToken;

        emit AITokenSet(agentId, aiToken);
    }   

    /**
     * @dev Get AI token.
     */
    function getAIToken(uint256 agentId) public view virtual returns (address) {
        return _aiTokens[agentId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[50] private __gap;
}