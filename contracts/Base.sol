// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Redistribution} from "./interfaces/Redistribution.sol";

contract Base {
    modifier onlyMC(uint256 gatheringID) {
        require(
                msg.sender == gatherings[gatheringID].mc,
                "Only MC can call this function."
        );
        _;
    }

    struct Gathering {
        address focalizer;
        bool isMutable;
        // TODO a singleton or a set of valid tokens
        address collection;
        Redistribution redistribution;
        address mc;
        uint256 ceremonyCounter;
        mapping (uint256 => Ceremony) ceremonies;
    }

    struct Ceremony {
        bool isCollectionComplete;
        address[] contributors;
    }

    uint256 gatheringCounter;

    mapping(uint256 => Gathering) public gatherings;
}
