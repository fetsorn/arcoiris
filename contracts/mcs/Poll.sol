// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Arcoiris} from "../Arcoiris.sol";
import {Mission} from "../interfaces/IRedistribution.sol";

contract Poll {
    modifier onlyPoller(uint256 pollID) {
        require(
            msg.sender == polls[pollID].poller,
            "Only poller can call this function."
        );
        _;
    }

    struct Poll {
        uint256 gatheringID;
        uint256 ceremonyID;
        address poller;
        mapping(address => bool) isEligibleVoter;
        address[] voters;
        mapping(address => Mission[]) votes;
        mapping(address => uint256) points;
    }

    Arcoiris arcoiris;

    uint256 public pollCounter;

    mapping(uint256 => Poll) internal polls;

    constructor(address _arcoiris) {
        arcoiris = Arcoiris(_arcoiris);
    }

    function getGatheringID(
        uint256 pollID
    ) external view returns (uint256 gatheringID) {
        return polls[pollID].gatheringID;
    }

    function getCeremonyID(
        uint256 pollID
    ) external view returns (uint256 ceremonyID) {
        return polls[pollID].ceremonyID;
    }

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
    }

    function endCollection(uint256 pollID) external onlyPoller(pollID) {
        arcoiris.endCollection(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID
        );
    }

    function commencePoll(uint256 pollID) external onlyPoller(pollID) {
        require(
            arcoiris.getIsCollectionEnded(
                polls[pollID].gatheringID,
                polls[pollID].ceremonyID
            ),
            "Poll: collection has not ended"
        );

        address[] memory contributors = arcoiris.getContributors(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID
        );

        for (uint256 i = 0; i < contributors.length; i++) {
            polls[pollID].isEligibleVoter[contributors[i]] = true;
        }
    }

    function vote(uint256 pollID, Mission[] memory votes) external {
        require(
            polls[pollID].isEligibleVoter[msg.sender],
            "Poll: voter is not eligible"
        );

        for (uint256 i = 0; i < votes.length; i++) {
            Mission memory vote = votes[i];

            require(
                polls[pollID].isEligibleVoter[vote.facilitator],
                "Poll: facilitator is not eligible"
            );

            polls[pollID].votes[msg.sender].push(votes[i]);
        }

        polls[pollID].voters.push(msg.sender);
    }

    function completePoll(uint256 pollID) external onlyPoller(pollID) {
        for (uint256 i = 0; i < polls[pollID].voters.length; i++) {
            Mission[] memory votes = polls[pollID].votes[
                polls[pollID].voters[i]
            ];

            for (uint256 j = 0; j < votes.length; j++) {
                Mission memory vote = votes[j];

                polls[pollID].points[vote.facilitator] += vote.share;
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

        arcoiris.redistribute(
            polls[pollID].gatheringID,
            polls[pollID].ceremonyID,
            siblings,
            priorities
        );
    }
}
