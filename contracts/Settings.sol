// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Base} from "./Base.sol";

contract Settings is Base {

    modifier onlyFocalizer(uint256 gatheringID) {
        require(
                msg.sender == gatherings[gatheringID].focalizer,
                "Only focalizer can call this function."
        );
        _;
    }

    modifier onlyMutable(uint256 gatheringID) {
        require(
                gatherings[gatheringID].isMutable,
                "Settings for this gathering are not mutable."
        );
        _;
    }

    function setFocalizer(
        uint256 gatheringID,
        address focalizer
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].focalizer = focalizer;
    }

    function setMC(
        uint256 gatheringID,
        address mc
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].mc = mc;
    }

    function setCollection(
        uint256 gatheringID,
        address collection
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].collection = collection;
    }
}
