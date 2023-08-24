// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Base} from "./Base.sol";
import {TBN} from "./Ceremony.sol";
import {Settings} from "./Settings.sol";
import {Redistribution} from "./interfaces/Redistribution.sol";

contract Arcoiris is Base, Settings, TBN {

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
}
