pragma solidity ^0.8.0;

import {CryptoAISubscriptionFeeUpgradeable} from "./CryptoAISubscriptionFeeUpgradeable.sol";
import "../libs/helpers/Errors.sol";

contract CryptoAI is CryptoAISubscriptionFeeUpgradeable {
    // deployer
    address public _deployer;
    // admins
    mapping(address => bool) public _admins;

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAdmin() {
        require(_admins[msg.sender], Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        string memory name,
        string memory symbol,
        address deployer
    ) initializer public {
        _deployer = deployer;

        __CryptoAI_init(name, symbol);
    }

    function changeDeployer(address newAdm) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function allowAdmin(address newAdm, bool allow) external onlyDeployer {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admins[newAdm] = allow;
    }

    function changeCryptoAiDataAddress(address newAddr) external onlyDeployer {
        require(newAddr != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);

        _setCryptoAIDataAddr(newAddr);
    }

    //@ERC721
    function mint(
        address to,
        uint256 dna,
        uint256[5] memory traits,
        string calldata agentName,
        string calldata agentAbility
    ) public virtual override onlyAdmin {
        super.mint(to, dna, traits, agentName, agentAbility);
    }

    uint256[50] private __gap;
}