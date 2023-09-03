// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Base} from "./Base.sol";

/// @title Sets settings of gatherings
/// @author Anton Davydov
contract Settings is Base {
    /// @notice Only allows functions if msg.sender is focalizer of the gathering
    modifier onlyFocalizer(uint256 gatheringID) {
        require(
                msg.sender == gatherings[gatheringID].focalizer,
                "Only focalizer can call this function."
        );
        _;
    }

    /// @notice Only allows functions if the gathering is mutable
    modifier onlyMutable(uint256 gatheringID) {
        require(
                gatherings[gatheringID].isMutable,
                "Settings for this gathering are not mutable."
        );
        _;
    }

    /// @notice Set address that can change gathering settings
    /// @param gatheringID The index of the gathering
    /// @param focalizer The address of new focalizer
    function setFocalizer(
        uint256 gatheringID,
        address focalizer
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].focalizer = focalizer;
        // TODO: emit event
    }

    /// @notice Set address that can organize ceremonies
    /// @param gatheringID The index of the gathering
    /// @param mc The address of new master of ceremonies
    function setMC(
        uint256 gatheringID,
        address mc
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].mc = mc;
        // TODO: emit event
    }

    /// @notice Set token valid for the gathering
    /// @param gatheringID The index of the gathering
    /// @param collection The address of new token
    function setCollection(
        uint256 gatheringID,
        address collection
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        gatherings[gatheringID].collection = collection;
        // TODO: emit event
    }
}
