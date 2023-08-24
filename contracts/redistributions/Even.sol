// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Redistribution} from "../interfaces/Redistribution.sol";

contract Even is Redistribution {

    struct Mission {
        address facilitator;
        uint256 priority;
    }

    function redistribute(bytes calldata _missions) external {
        Mission[] memory missions = abi.decode(_missions, (Mission[]));
    }
}
