// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {CryptoAIUpgradeable} from "./CryptoAIUpgradeable.sol";
import {IEAI721SubscriptionFee} from "../interfaces/IEAI721SubscriptionFee.sol";

/**
 * @dev Extension of {CryptoAIUpgradeable} that allows token owner to set subscription fee.
 * This is useful for subscription-based services or products.
 */
abstract contract CryptoAISubscriptionFeeUpgradeable is Initializable, IEAI721SubscriptionFee, CryptoAIUpgradeable {

    mapping(uint256 => uint256) private _subscriptionFees;
    mapping(uint256 => address) private _aiTokens;

    event SubscriptionFeeSet(uint256 indexed agentId, uint256 fee);
    event AITokenSet(uint256 indexed agentId, address indexed aiToken);

    function __CryptoAISubscriptionFee_init() internal onlyInitializing {
    }

    function __CryptoAISubscriptionFee_init_unchained() internal onlyInitializing {
    }

    /**
     * @dev Set subscription.
     */
    function setSubscriptionFee(uint256 agentId, uint256 fee) public virtual onlyAgentOwner(agentId){
        _subscriptionFees[agentId] = fee;

        emit SubscriptionFeeSet(agentId, fee);
    }   

    /**
     * @dev Get subscription.
     */
    function subscriptionFee(uint256 agentId) public view virtual returns (uint256) {
        return _subscriptionFees[agentId];
    }

    /**
     * @dev Set AI token address.
     */
    function setAItokenAddress(uint256 agentId, address newAIToken) public virtual onlyAgentOwner(agentId){
        _aiTokens[agentId] = newAIToken;

        emit AITokenSet(agentId, newAIToken);
    }   

    /**
     * @dev Get AI token.
     */
    function aiToken(uint256 agentId) public view virtual returns (address) {
        return _aiTokens[agentId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     */
    uint256[50] private __gap;
}