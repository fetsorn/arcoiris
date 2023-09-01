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

    mapping(uint256 => Gathering) gatherings;

    function getContributors(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external returns(address[] memory) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.contributors;
    }

    function getIsCollectionComplete(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external returns(bool) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.isCollectionComplete;
    }
}
