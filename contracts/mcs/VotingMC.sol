// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Arcoiris} from "../Arcoiris.sol";
import {Mission} from "../interfaces/IRedistribution.sol";

/// @title Hosts redistribution ceremonies according to voting
/// @author Anton Davydov
contract VotingMC {
    /// @notice Only allows functions if msg.sender is the organizer of the poll
    modifier onlyPoller(uint256 pollID) {
        require(
            msg.sender == polls[pollID].poller,
            "Only poller can call this function."
        );
        _;
    }

    /// @notice Information about a poll
    struct Poll {
        uint256 gatheringID;
        uint256 ceremonyID;
        address poller;
        mapping(address => bool) isEligibleVoter;
        address[] voters;
        mapping(address => Mission[]) votes;
        mapping(address => uint256) points;
    }

    /// @notice The Arcoíris contract
    Arcoiris arcoiris;

    /// @notice The number of created polls
    uint256 public pollCounter;

    /// @notice Indexed map of poll structs
    mapping(uint256 => Poll) internal polls;

    constructor(address _arcoiris) {
        arcoiris = Arcoiris(_arcoiris);
    }

    /// @notice Get ID of the gathering associated with a poll
    /// @param pollID The index of a poll
    /// @return gatheringID The index of a gathering
    function getGatheringID(
        uint256 pollID
    ) external view returns (uint256 gatheringID) {
        return polls[pollID].gatheringID;
    }

    /// @notice Get ID of the ceremony associated with a poll
    /// @param pollID The index of a poll
    /// @return gatheringID The index of a ceremony
    function getCeremonyID(
        uint256 pollID
    ) external view returns (uint256 ceremonyID) {
        return polls[pollID].ceremonyID;
    }

    /// @notice Create a poll and a redistribution ceremony
    /// @param gatheringID The index of the gathering
    /// @return pollID The index of the new poll
    function createPoll(uint256 gatheringID) external returns (uint256 pollID) {
        require(
            arcoiris.getMC(gatheringID) == address(this),
            "Poll: is not MC"
        );

        pollID = pollCounter;

        polls[pollID].poller = msg.sender;

        polls[pollID].gatheringID = gatheringID;

        uint256 ceremonyID = arcoiris.createCeremony(gatheringID);

        polls[pollID].ceremonyID = ceremonyID;

        pollCounter++;
        // TODO: emit event
    }

    /// @notice End collection and start accepting votes
    /// @param pollID The index of the poll
    function commencePoll(uint256 pollID) external onlyPoller(pollID) {
        arcoiris.endCollection(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID
        );

        address[] memory contributors = arcoiris.getContributors(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID
        );

        for (uint256 i = 0; i < contributors.length; i++) {
            polls[pollID].isEligibleVoter[contributors[i]] = true;
        }
        // TODO: emit event
    }

    /// @notice Place a vote for priority of each ceremony member
    /// @param pollID The index of the poll
    function vote(uint256 pollID, Mission[] memory votes) external {
        require(
            polls[pollID].isEligibleVoter[msg.sender],
            "Poll: voter is not eligible"
        );

        for (uint256 i = 0; i < votes.length; i++) {
            require(
                polls[pollID].isEligibleVoter[votes[i].facilitator],
                "Poll: facilitator is not eligible"
            );

            polls[pollID].votes[msg.sender].push(votes[i]);
        }

        polls[pollID].voters.push(msg.sender);
        // TODO: emit event
    }

    /// @notice Redistribute wealth according to voting results
    /// @param pollID The index of the poll
    function completePoll(uint256 pollID) external onlyPoller(pollID) {
        for (uint256 i = 0; i < polls[pollID].voters.length; i++) {
            Mission[] memory votes = polls[pollID].votes[
                polls[pollID].voters[i]
            ];

            for (uint256 j = 0; j < votes.length; j++) {
                polls[pollID].points[votes[j].facilitator] += votes[j].share;
            }
        }

        address[] memory siblings = arcoiris.getContributors(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID
        );

        uint256[] memory priorities = new uint256[](siblings.length);

        for (uint256 i = 0; i < siblings.length; i++) {
            priorities[i] =
                polls[pollID].points[siblings[i]] /
                polls[pollID].voters.length;
        }
        
        // TODO: emit event

        arcoiris.redistribute(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID,
            siblings,
            priorities
        );
    }
}
