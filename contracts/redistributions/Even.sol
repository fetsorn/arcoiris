// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution, Mission} from "../interfaces/IRedistribution.sol";

/// @title Redistribute wealth evenly
/// @author Anton Davydov
contract Even is IRedistribution {
    /// @notice Version of the contract, bumped on each deployment
    string public constant VERSION = "0.0.1";

    /// @notice Redistribute contributions among siblings evenly, ignoring the priorities
    /// @param siblings The list of ceremony members
    /// @param priorities Arbitrary number associated with each ceremony member
    /// @return missions Shares of wealth for each ceremony member
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 amount
    ) external pure returns (Mission[] memory missions) {
        require(siblings.length == priorities.length, "E1");

        missions = new Mission[](siblings.length);

        uint256 sum;

        for (uint256 i = 0; i < siblings.length; i++) {
            uint256 share = amount / priorities.length;

            missions[i] = Mission(siblings[i], share);

            sum += share;
        }

        if (sum < amount) {
            missions[0] = Mission(siblings[0], amount - sum);
        }

        return missions;
    }
}
