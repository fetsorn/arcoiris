// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution} from "./interfaces/IRedistribution.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/// @title Stores state of gatherings and ceremonies
/// @author Anton Davydov
contract Base is IERC721Receiver {
    /// @notice Information about a redistribution community
    struct Gathering {
        address focalizer;
        bool isMutable;
        address collection;
        IRedistribution redistribution;
        address mc;
        uint256 ceremonyCounter;
        mapping (uint256 => Ceremony) ceremonies;
    }

    /// @notice Information about a redistribution ceremony
    struct Ceremony {
        bool isCollectionEnded;
        uint256[] contributions;
        address[] contributors;
    }

    /// @notice The number of created gatherings
    uint256 internal gatheringCounter;

    /// @notice Indexed map of gathering structs
    mapping(uint256 => Gathering) internal gatherings;
    
    /// @notice Version of the contract, bumped on each deployment
    string public constant VERSION = "0.0.1";

    /// @notice Get the number of created gatherings
    /// @return The number of created gatherings
    function getGatheringCounter() external view returns (uint256) {
        return gatheringCounter;
    }

    /// @notice Get the address of the creator of the gathering
    /// @param gatheringID The index of the gathering
    /// @return The creator of the gathering
    function getFocalizer(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].mc;
    }

    /// @notice Get the address of the token valid for the gathering
    /// @param gatheringID The index of the gathering
    /// @return The token valid for the gathering
    function getCollection(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].collection;
    }
    
    /// @notice Get the address of the master of ceremonies for the gathering
    /// @param gatheringID The index of the gathering
    /// @return The master of ceremonies for the gathering
    function getMC(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].mc;
    }

    /// @notice Get true if focalizer can change gathering settings
    /// @param gatheringID The index of the gathering
    /// @return True if focalizer can change gathering settings
    function getIsMutable(uint256 gatheringID) external view returns (bool) {
        return gatherings[gatheringID].isMutable;
    }

    /// @notice Get the list of ceremony members
    /// @param gatheringID The index of the gathering
    /// @param ceremonyID The index of the ceremony
    /// @return The list of ceremony members
    function getContributors(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(address[] memory) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.contributors;
    }

    /// @notice Get the list of token IDs contributed to the ceremony
    /// @param gatheringID The index of the gathering
    /// @param ceremonyID The index of the ceremony
    /// @return The list of token IDs contributed to the ceremony
    function getContributions(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(uint256[] memory) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.contributions;
    }

    /// @notice Get true if collection of contributions for the ceremony has stopped
    /// @param gatheringID The index of the gathering
    /// @param ceremonyID The index of the ceremony
    /// @return True if collection of contributions for the ceremony has stopped
    function getIsCollectionEnded(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(bool) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.isCollectionEnded;
    }

    /// @notice Callback to support ERC721 safeTransferFrom
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
