// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Arcoiris} from "../Arcoiris.sol";

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
        // TODO from missions from votes

        // TODO form missions bytes
        bytes memory missions = new bytes(32);

        arcoiris.redistribute(gatheringID, ceremonyID, missions);
    }
}
