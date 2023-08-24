// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Base} from "./Base.sol";
import {Settings} from "./Settings.sol";
import {Redistribution} from "./interfaces/Redistribution.sol";

contract Arcoiris is Base, Settings {
    function createGathering(
        address collection,
        Redistribution redistribution,
        address mc,
        bool isMutable
    ) external returns (uint256 gatheringID) {
        gatheringID = gatheringCounter;

        gatheringCounter++;

        Gathering storage gatheringNew = gatherings[gatheringID];

        gatheringNew.collection = collection;

        gatheringNew.redistribution = redistribution;

        gatheringNew.mc = mc;

        gatheringNew.isMutable = isMutable;
    }

    function createCeremony(
        uint256 gatheringID
    ) external onlyMC(gatheringID) returns (
        uint256 ceremonyID
    ) {
        Gathering storage gathering = gatherings[gatheringID];

        ceremonyID = gathering.ceremonyCounter;

        gathering.ceremonyCounter++;
    }

    function contribute(
        uint256 gatheringID,
        uint256 ceremonyID,
        address token,
        uint256 tokenID
    ) external {
        // TODO transfer tokenID from msg.sender

        gatherings[gatheringID].ceremonies[ceremonyID].contributors.push(msg.sender);
    }

    function endCollection(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external onlyMC(gatheringID) {
        gatherings[gatheringID].ceremonies[ceremonyID].isCollectionComplete = true;
    }

    function redistribute(
        uint256 gatheringID,
        uint256 ceremonyID,
        bytes calldata missions
    ) external onlyMC(gatheringID) {
        // TODO: fallback to even algorithm
        gatherings[gatheringID].redistribution.redistribute(missions);
    }
}
