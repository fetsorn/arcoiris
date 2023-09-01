// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;
    struct Mission {
        address facilitator;
        uint256 priority;
    }

interface Redistribution {
    function redistribute(
        address[] calldata addresses,
        uint256[] calldata priorities,
        uint256 amount
    ) external returns (Mission[] calldata missions);
}
