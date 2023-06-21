pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../libs/helpers/Errors.sol";
import "../erc20/SOULGMVotesCompToken.sol";
import "../nfts/SOUL.sol";

contract SOULGMDAO is GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable {
    address public _admin;
    address public _paramAddr;
    address public _votingToken;
    address public _soul;
    address public _gmToken;

    uint256 public _votingPeriods;
    uint256 public _votingDelays;
    uint256 public _proposalThresholdSoul;
    uint256 public _proposalThresholdGM;
    uint256 public _voteThresholdSoul;
    uint256 public _voteThresholdGM;

    function initialize(string memory name,
        address admin,
        address paramAddr,
        address votingToken,
        address soul,
        address gmToken
    ) initializer public {
        require(admin != Errors.ZERO_ADDR && paramAddr != Errors.ZERO_ADDR && address(votingToken) != Errors.ZERO_ADDR, Errors.INV_ADD);
        _admin = admin;
        _paramAddr = paramAddr;
        _soul = soul;
        _votingToken = votingToken;
        _gmToken = gmToken;
        _proposalThresholdSoul = _voteThresholdSoul = 1;
        _proposalThresholdGM = _voteThresholdGM = 1 * 10 ** 18;

        // 1 day
        _votingDelays = 60 * 24 * 1 / 10;
        // 7 days
        _votingPeriods = 60 * 24 * 7 / 10;

        __Governor_init(name);
        __GovernorCompatibilityBravo_init();
        __GovernorVotes_init(IVotesUpgradeable(votingToken));
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

    function changeVoteDelay(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_votingDelays != _new) {
            _votingDelays = _new;
        }
    }

    function changeVotePeriod(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_votingPeriods != _new) {
            _votingPeriods = _new;
        }
    }

    function changeVotingToken(address _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_votingToken != _new) {
            _votingToken = _new;
            token = IVotesUpgradeable(_new);
        }
    }

    function changeGMToken(address _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_gmToken != _new) {
            _gmToken = _new;
        }
    }

    function changeSOUL(address _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_soul != _new) {
            _soul = _new;
        }
    }

    function changeProposalThresholdSoul(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_proposalThresholdSoul != _new) {
            _proposalThresholdSoul = _new;
        }
    }

    function changeProposalThresholdGM(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_proposalThresholdGM != _new) {
            _proposalThresholdGM = _new;
        }
    }

    function changeVoteThresholdSoul(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_voteThresholdSoul != _new) {
            _voteThresholdSoul = _new;
        }
    }

    function changeVoteThresholdGM(uint256 _new) external {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        if (_voteThresholdGM != _new) {
            _voteThresholdGM = _new;
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
        return 0;
    }

    function castVote(uint256 proposalId, uint8 support) public virtual override(GovernorUpgradeable, IGovernorUpgradeable) returns (uint256) {
        require(SOUL(_soul).balanceOf(msg.sender) > _voteThresholdSoul, "miss Soul");
        require(SOUL(_soul)._biddingBalance(msg.sender, _gmToken)// gm in soul deposit
        // gm balance
        + IERC20Upgradeable(_gmToken).balanceOf(msg.sender)
        // gm deposit voting
        + IERC20Upgradeable(_votingToken).balanceOf(msg.sender) > _voteThresholdGM, "miss GM");
        return super.castVote(proposalId, support);
    }

    function _getVotes(
        address account,
        uint256 blockNumber,
        bytes memory params
    ) internal view virtual override(GovernorUpgradeable, GovernorVotesUpgradeable) returns (uint256) {
        uint256 votes = super._getVotes(account, blockNumber, params);
        return Math.log10(votes);
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
        require(SOUL(_soul).balanceOf(msg.sender) > _proposalThresholdSoul, "miss SOUL");
        require(SOUL(_soul)._biddingBalance(msg.sender, _gmToken)// gm in soul deposit
        // gm balance
        + IERC20Upgradeable(_gmToken).balanceOf(msg.sender)
        // gm deposit voting
        + IERC20Upgradeable(_votingToken).balanceOf(msg.sender) > _proposalThresholdGM, "miss GM");

        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    override(GovernorUpgradeable)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
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
