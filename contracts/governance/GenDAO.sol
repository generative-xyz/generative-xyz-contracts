pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";

contract GenDAO is GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable {
    address public _admin;
    address public _paramAddr;
    IGENToken public _votingToken;

    uint256 public _proposalThresholdPercent; // percent
    uint256 public _quorumVotePercent; // percent

    uint256 public _votingPeriods;
    uint256 public _votingDelays;

    function initialize(string memory name,
        address admin,
        address paramAddr,
        IGENToken votingToken
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR && address(votingToken) != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;

        _votingToken = votingToken;
        // hold percentage to make propose
        // at least 5%
        _proposalThresholdPercent = 500;
        // quorum percentage
        // at least 1%
        _quorumVotePercent = 100;

        // 1 day
        _votingDelays = 6575;
        // 7 days
        _votingPeriods = 46027;

        __Governor_init(name);
        __GovernorCompatibilityBravo_init();
        __GovernorVotes_init(votingToken);
        __GovernorVotesQuorumFraction_init(50);
    }

    //
    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeParamAddress(address newAddr) external {
        require(msg.sender == _admin && newAddr != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change param address
        if (_paramAddr != newAddr) {
            _paramAddr = newAddr;
        }
    }

    function changeQuorumVotes(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_quorumVotePercent != _new) {
            _quorumVotePercent = _new;
        }
    }

    function changeProposalThreshold(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_proposalThresholdPercent != _new) {
            _proposalThresholdPercent = _new;
        }
    }

    function changeVoteDelay(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingDelays != _new) {
            _votingDelays = _new;
        }
    }

    function changeVotePeriod(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingPeriods != _new) {
            _votingPeriods = _new;
        }
    }

    function changeVotingToken(IGENToken _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingToken != _new) {
            _votingToken = _new;
            token = _new;
        }
    }

    function withdraw(address erc20Addr, uint256 amount) external virtual {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        bool success;
        if (erc20Addr == address(0x0)) {
            require(address(this).balance >= amount);
            (success,) = msg.sender.call{value : amount}("");
            require(success);
        } else {
            IERC20Upgradeable tokenERC20 = IERC20Upgradeable(erc20Addr);
            // transfer erc-20 token
            require(tokenERC20.transfer(msg.sender, amount));
        }
    }

    /* @DefineVoting
    */
    function votingDelay() public view override returns (uint256) {
        return _votingDelays;
    }

    function votingPeriod() public view override returns (uint256) {
        return _votingPeriods;
    }

    function proposalThreshold() public view override returns (uint256) {
        return _proposalThresholdPercent * _votingToken.totalSupply() / 10000;
    }

    function quorumVotes() public view override returns (uint256) {
        return _quorumVotePercent * _votingToken.totalSupply() / 10000;
    }

    /* @notice The functions below are overrides required by Solidity.
    */
    function state(uint256 proposalId)
    public
    view
    override(GovernorUpgradeable, IGovernorUpgradeable)
    returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
    public
    override(GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable)
    returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    override(GovernorUpgradeable)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual override(GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    override(GovernorUpgradeable)
    returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
    internal
    view
    override(GovernorUpgradeable)
    returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(GovernorUpgradeable, IERC165Upgradeable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /* @OverrideUnusedFunctions
    */
    function proposalEta(uint256) public pure override returns (uint256) {
        return 0;
    }

    function timelock() public pure override returns (address) {
        return address(0x0);
    }

    function queue(
        address[] memory,
        uint256[] memory,
        bytes[] memory,
        bytes32
    ) public pure override returns (uint256) {
        return 0;
    }
}
