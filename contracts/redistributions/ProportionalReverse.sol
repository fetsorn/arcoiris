// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution, Mission} from "../interfaces/IRedistribution.sol";

/// @title Redistribute wealth in reverse proportion to priorities
/// @author Anton Davydov
contract ProportionalReverse is IRedistribution {
    /// @notice Version of the contract, bumped on each deployment
    string public constant VERSION = "0.0.1";

    /// @notice Redistribute contributions among siblings in reverse proportion to priorities
    /// @param siblings The list of ceremony members
    /// @param priorities Arbitrary number associated with each ceremony member
    /// @return missions Shares of wealth for each ceremony member
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 amount
    ) external pure returns (Mission[] memory missions) {
        require(siblings.length == priorities.length, "E1");

        uint256 sumPriorities;

        for (uint256 i = 0; i < priorities.length; i++) {
            sumPriorities += priorities[i];
        }

        missions = new Mission[](siblings.length);

        uint256 sumShares;
        uint256 winnerIndex;
        uint256 priorityHighest;

        for (uint256 i = 0; i < siblings.length; i++) {
            // first sibling with highest priority is winner
            if (priorities[i] > priorityHighest) {
                priorityHighest = priorities[i];

                winnerIndex = i;
            }

            // TODO: least priority is largest share
            uint256 share = (amount * priorities[i]) / sumPriorities;

            sumShares += share;

            missions[i] = Mission(siblings[i], share);
        }

        // winner takes remainder
        if (sumShares < amount) {
            uint256 remainder = amount - sumShares;

            uint256 share = missions[winnerIndex].share + remainder;

            missions[winnerIndex] = Mission(siblings[winnerIndex], share);
        }

        return missions;
    }
}
