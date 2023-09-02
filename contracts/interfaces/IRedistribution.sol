// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;
struct Mission {
    address facilitator;
    uint256 share;
}

interface IRedistribution {
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 contributions
    ) external pure returns (Mission[] calldata missions);
}
