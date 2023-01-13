pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";

import "../libs/helpers/Errors.sol";
import "../interfaces/IGENToken.sol";

contract GenDAO is GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable, GovernorTimelockControlUpgradeable {
    address public _admin;
    address public _paramAddr;
    IGENToken public _votingToken;

    uint256 public _proposalThreshold; // percent
    uint256 public _quorumVote; // percent

    uint256 public _votingPeriod;
    uint256 public _votingDelay;

    function initialize(string memory name,
        address admin,
        address paramAddr,
        IGENToken votingToken,
        TimelockControllerUpgradeable timelock
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR && address(votingToken) != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;

        _votingToken = votingToken;
        // hold percentage to make propose
        // ~ 5%
        _proposalThreshold = 0;
        // hold percentage for cast vote
        // ~ 1%
        _quorumVote = 100;

        // 1 day
        _votingDelay = 6575;
        // 7 days
        _votingPeriod = 46027;

        __Governor_init(name);
        __GovernorCompatibilityBravo_init();
        __GovernorVotes_init(votingToken);
        __GovernorVotesQuorumFraction_init(50);
        __GovernorTimelockControl_init(timelock);
    }

    //
    function changeAdmin(address newAdm) external {
        require(msg.sender == _admin && newAdm != address(0), Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_admin != newAdm) {
            _admin = newAdm;
        }
    }

    function changeQuorumVotes(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_quorumVote != _new) {
            _quorumVote = _new;
        }
    }

    function changeProposalThreshold(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_proposalThreshold != _new) {
            _proposalThreshold = _new;
        }
    }

    function changeVoteDelay(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingDelay != _new) {
            _votingDelay = _new;
        }
    }

    function changeVotePeriod(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingPeriod != _new) {
            _votingPeriod = _new;
        }
    }

    function changeVotingToken(IGENToken _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        // change admin
        if (_votingToken != _new) {
            _votingToken = _new;
        }
    }

    /* @DefineVoting
    */
    function votingDelay() public view override returns (uint256) {
        return _votingDelay;
    }

    function votingPeriod() public view override returns (uint256) {
        return _votingPeriod;
    }

    function proposalThreshold() public view override returns (uint256) {
        return _proposalThreshold / 10000 * _votingToken.totalSupply();
    }

    function quorumVotes() public view override returns (uint256) {
        return _quorumVote / 10000 * _votingToken.totalSupply();
    }

    /* @notice The functions below are overrides required by Solidity.
    */
    function state(uint256 proposalId)
    public
    view
    override(GovernorUpgradeable, IGovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
    public
    override(GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable, IGovernorUpgradeable)
    returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
    internal
    view
    override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(GovernorUpgradeable, IERC165Upgradeable, GovernorTimelockControlUpgradeable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /* @OverrideUnusedFunctions
    */
    function proposalEta(uint256) public pure override(GovernorTimelockControlUpgradeable, IGovernorTimelockUpgradeable) returns (uint256) {
        return 0;
    }

    function timelock() public pure override(GovernorTimelockControlUpgradeable, IGovernorTimelockUpgradeable) returns (address) {
        return address(0x0);
    }

    function queue(
        address[] memory,
        uint256[] memory,
        bytes[] memory,
        bytes32
    ) public pure override(GovernorTimelockControlUpgradeable, IGovernorTimelockUpgradeable) returns (uint256) {
        return 0;
    }

}
