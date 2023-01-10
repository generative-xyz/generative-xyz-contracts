pragma solidity ^0.8.0;

/*
import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";

import "../libs/helpers/Errors.sol";

contract GenDAO is GovernorUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable {
    address public _admin;

    function initialize(string memory name, address admin, IVotesUpgradeable votingToken) initializer public {
        require(admin != Errors.ZERO_ADDR, Errors.INV_ADD);
        __Governor_init(name);
        __GovernorVotes_init(votingToken);
        __GovernorVotesQuorumFraction_init(50);
    }

    // solhint-disable-next-line func-name-mixedcase
    function COUNTING_MODE() public pure virtual override returns (string memory) {
        return "support=bravo&quorum=bravo";
    }

    function votingPeriod() public pure override returns (uint256) {
        // one day
        return 7200;
    }

    function votingDelay() public pure override returns (uint256) {
        // 7 days
        return 50400;
    }

    function hasVoted(uint256 proposalId, address account) public view virtual override returns (bool) {
        //        return _proposalDetails[proposalId].receipts[account].hasVoted;
        return false;
    }

    function _voteSucceeded(uint256 proposalId) internal view virtual override returns (bool) {
        //        ProposalDetails storage details = _proposalDetails[proposalId];
        //        return details.forVotes > details.againstVotes;
        return true;
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory // params
    ) internal virtual override {
        //        ProposalDetails storage details = _proposalDetails[proposalId];
        //        Receipt storage receipt = details.receipts[account];
        //
        //        require(!receipt.hasVoted, "GovernorCompatibilityBravo: vote already cast");
        //        receipt.hasVoted = true;
        //        receipt.support = support;
        //        receipt.votes = SafeCastUpgradeable.toUint96(weight);
        //
        //        if (support == uint8(VoteType.Against)) {
        //            details.againstVotes += weight;
        //        } else if (support == uint8(VoteType.For)) {
        //            details.forVotes += weight;
        //        } else if (support == uint8(VoteType.Abstain)) {
        //            details.abstainVotes += weight;
        //        } else {
        //            revert("GovernorCompatibilityBravo: invalid vote type");
        //        }
    }

    function _quorumReached(uint256 proposalId) internal view virtual override returns (bool) {
        //        ProposalDetails storage details = _proposalDetails[proposalId];
        //        return quorum(proposalSnapshot(proposalId)) <= details.forVotes;
        return true;
    }

}
*/
