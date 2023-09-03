// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Base} from "./Base.sol";

/// @title Sets settings of gatherings
/// @author Anton Davydov
contract Settings is Base {
    /// @notice Emits when a gathering focalizer is changed
    /// @param gatheringID The index of the gathering
    /// @param focalizerOld The old organizer of the gathering
    /// @param focalizerNew The new organizer of the gathering
    event SetFocalizer(
        uint256 indexed gatheringID,
        address indexed focalizerOld,
        address indexed focalizerNew
    );
    
    /// @notice Emits when a master of ceremonies is changed
    /// @param gatheringID The index of the gathering
    /// @param mcOld The old master of ceremonies
    /// @param mcNew The new master of ceremonies
    event SetMC(
        uint256 indexed gatheringID,
        address indexed mcOld,
        address indexed mcNew
    );
    
    // TODO add and remove token addresses from list of valid wealth
    
    /// @notice Emits when a token valid for gathering is changed
    /// @param gatheringID The index of new gathering
    /// @param collectionOld The old token valid for the gathering
    /// @param collectionNew The new token valid for the gathering
    event SetCollection(
        uint256 indexed gatheringID,
        address indexed collectionOld,
        address indexed collectionNew
    );
    
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
    /// @param focalizerNew The address of new focalizer
    function setFocalizer(
        uint256 gatheringID,
        address focalizerNew
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        emit SetFocalizer(
            gatheringID, 
            gatherings[gatheringID].focalizer,
            focalizerNew
        );
        
        gatherings[gatheringID].focalizer = focalizerNew;
    }

    /// @notice Set address that can organize ceremonies
    /// @param gatheringID The index of the gathering
    /// @param mcNew The address of new master of ceremonies
    function setMC(
        uint256 gatheringID,
        address mcNew
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        emit SetMC(
            gatheringID, 
            gatherings[gatheringID].mc,
            mcNew
        );
        
        gatherings[gatheringID].mc = mcNew;
    }

    /// @notice Set token valid for the gathering
    /// @param gatheringID The index of the gathering
    /// @param collectionNew The address of new token
    function setCollection(
        uint256 gatheringID,
        address collectionNew
    )
        external
        onlyFocalizer(gatheringID)
        onlyMutable(gatheringID)
    {
        emit SetCollection(
            gatheringID, 
            gatherings[gatheringID].collection,
            collectionNew
        );
        
        gatherings[gatheringID].collection = collectionNew;
    }
}
