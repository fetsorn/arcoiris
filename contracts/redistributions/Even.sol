// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution, Mission} from "../interfaces/IRedistribution.sol";

contract Even is IRedistribution {
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 amount
    ) external pure returns (Mission[] memory missions) {
        require(siblings.length == priorities.length, "E1");

        missions = new Mission[](siblings.length);

        for (uint256 i = 0; i < siblings.length; i++) {
            missions[i] = Mission(siblings[i], amount / priorities.length);
        }

        return missions;
    }
}
