// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IRedistribution} from "./interfaces/IRedistribution.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Base is IERC721Receiver {
    struct Gathering {
        address focalizer;
        bool isMutable;
        address collection;
        IRedistribution redistribution;
        address mc;
        uint256 ceremonyCounter;
        mapping (uint256 => Ceremony) ceremonies;
    }

    struct Ceremony {
        bool isCollectionEnded;
        uint256[] contributions;
        address[] contributors;
    }

    uint256 internal gatheringCounter;

    mapping(uint256 => Gathering) internal gatherings;

    function getGatheringCounter() external view returns (uint256) {
        return gatheringCounter;
    }

    function getFocalizer(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].mc;
    }

    function getCollection(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].collection;
    }

    function getMC(uint256 gatheringID) external view returns (address) {
        return gatherings[gatheringID].mc;
    }

    function getIsMutable(uint256 gatheringID) external view returns (bool) {
        return gatherings[gatheringID].isMutable;
    }

    function getContributors(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(address[] memory) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.contributors;
    }

    function getContributions(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(uint256[] memory) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.contributions;
    }

    function getIsCollectionEnded(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external view returns(bool) {
        Gathering storage gathering = gatherings[gatheringID];

        Ceremony storage ceremony = gathering.ceremonies[ceremonyID];

        return ceremony.isCollectionEnded;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
