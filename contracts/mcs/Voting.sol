// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Arcoiris} from "../Arcoiris.sol";
import {Mission} from "../interfaces/Redistribution.sol";

contract Voting {
    modifier onlyPoller() {
        require(msg.sender == poller, "Only poller can call this function.");
        _;
    }

    struct Vote {
        address facilitator;
        uint256 vote;
    }

    address public poller;
    Arcoiris public arcoiris;
    uint256 public gatheringID;
    uint256 public ceremonyID;
    address[] siblings;
    uint256[] priorities;

    constructor(Arcoiris _arcoiris, uint256 _gatheringID, uint256 _ceremonyID) {
        arcoiris = _arcoiris;
        gatheringID = _gatheringID;
        ceremonyID = _ceremonyID;
    }

    mapping(address => bool) isEligible;

    mapping(address => Vote[]) public votes;

    function vote(Vote[] memory _votes) external {
        require(isEligible[msg.sender]);

        for (uint i = 0; i < _votes.length; i++) {
            votes[msg.sender].push(_votes[i]);
        }
    }

    function commenceVoting(
        address[] memory eligibleVoters
    ) external onlyPoller {
        for (uint i = 0; i < eligibleVoters.length; i++) {
            isEligible[eligibleVoters[i]] = true;
        }
    }

    function completeVoting() external onlyPoller {
        // TODO form sibling priorities from votes

        siblings.push(address(0));
        priorities.push(0);

        arcoiris.redistribute(gatheringID, ceremonyID, siblings, priorities);
    }
}
