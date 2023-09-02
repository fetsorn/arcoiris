// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution, Mission} from "../interfaces/IRedistribution.sol";

contract Proportional is IRedistribution {
    function redistribute(
        address[] calldata siblings,
        uint256[] calldata priorities,
        uint256 amount
    ) external pure returns (Mission[] memory missions) {
        require(siblings.length == priorities.length, "E1");

        uint256 sum;

        for (uint256 i = 0; i < priorities.length; i++) {
            sum += priorities[i];
        }

        missions = new Mission[](siblings.length);

        for (uint256 i = 0; i < siblings.length; i++) {
            missions[i] = Mission(siblings[i], (amount * priorities[i]) / sum);
        }

        return missions;
    }
}
