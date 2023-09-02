// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Settings} from "./Settings.sol";
import {IRedistribution, Mission} from "./interfaces/IRedistribution.sol";

contract Arcoiris is Settings {
    modifier onlyMC(uint256 gatheringID) {
        require(
                msg.sender == gatherings[gatheringID].mc,
                "Only MC can call this function."
        );
        _;
    }

    function createGathering(
        address collection,
        IRedistribution redistribution,
        address mc,
        bool isMutable
    ) external returns (uint256 gatheringID) {
        gatheringID = gatheringCounter;

        Gathering storage gatheringNew = gatherings[gatheringID];

        gatheringNew.collection = collection;

        gatheringNew.redistribution = redistribution;

        gatheringNew.mc = mc;

        gatheringNew.isMutable = isMutable;

        gatheringCounter++;
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
        address tokenAddress,
        uint256 tokenID
    ) external {
        IERC721 token = IERC721(tokenAddress);

        token.safeTransferFrom(msg.sender, address(this), tokenID);

        require(this.getCollection(gatheringID) == tokenAddress);

        gatherings[gatheringID].ceremonies[ceremonyID].contributions.push(tokenID);

        gatherings[gatheringID].ceremonies[ceremonyID].contributors.push(msg.sender);
    }

    function endCollection(
        uint256 gatheringID,
        uint256 ceremonyID
    ) external onlyMC(gatheringID) {
        gatherings[gatheringID].ceremonies[ceremonyID].isCollectionEnded = true;
    }

    function redistribute(
        uint256 gatheringID,
        uint256 ceremonyID,
        address[] memory siblings,
        uint256[] memory priorities
    ) external onlyMC(gatheringID) {
        Mission[] memory missions = gatherings[gatheringID].redistribution.redistribute(
            siblings,
            priorities,
            this.getContributions(gatheringID, ceremonyID).length
        );

        IERC721 token = IERC721(gatherings[gatheringID].collection);

        for (uint256 i = 0; i < missions.length; i++) {
            Mission memory mission = missions[i];

            for (uint256 j = 0; j < mission.share; j ++) {
                uint256[] memory contributions = this.getContributions(gatheringID, ceremonyID);

                token.safeTransferFrom(
                    address(this),
                    mission.facilitator,
                    contributions[contributions.length-1]
                );

                gatherings[gatheringID].ceremonies[ceremonyID].contributions.pop();
            }
        }
    }
}
