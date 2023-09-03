// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution, Mission} from "../interfaces/IRedistribution.sol";

/// @title Redistribute wealth in proportion to priorities
/// @author Anton Davydov
contract Proportional is IRedistribution {
    /// @notice Redistribute contributions among siblings in proportion to priorities
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
