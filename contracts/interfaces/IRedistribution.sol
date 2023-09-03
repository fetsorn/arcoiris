// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

/// @notice Information about the share of wealth redistributed to a ceremony member
struct Mission {
    address facilitator;
    uint256 share;
}

/// @title Common interface for redistribution algorithm implementations
/// @author Anton Davydov
interface IRedistribution {
    /// @notice Redistribute contributions among siblings according to priorities and an arbitrary algorithm
    /// @param siblings The list of ceremony members
    /// @param priorities Arbitrary number associated with each ceremony member
    /// @param amount The amount of wealth to redistribute
    /// @return missions Shares of wealth for each ceremony member
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 amount
    ) external pure returns (Mission[] calldata missions);
}
