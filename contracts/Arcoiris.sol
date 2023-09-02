// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {Settings} from "./Settings.sol";
import {IRedistribution, Mission} from "./interfaces/IRedistribution.sol";

contract Arcoiris is Settings {
    event CreateGathering(
        uint256 indexed gatheringID,
        address indexed focalizer,
        address indexed mc,
        address collection,
        address redistribution,
        bool isMutable
    );

    event CreateCeremony(
        uint256 indexed gatheringID,
        uint256 indexed ceremonyID
    );

    modifier onlyMC(uint256 gatheringID) {
        require(
                msg.sender == gatherings[gatheringID].mc,
                "Only MC can call this function."
        );
        _;
    }

    function createGathering(
        address collection,
        address redistribution,
        address mc,
        bool isMutable
    ) external returns (uint256 gatheringID) {
        gatheringID = gatheringCounter;

        Gathering storage gatheringNew = gatherings[gatheringID];

        gatheringNew.collection = collection;

        gatheringNew.redistribution = IRedistribution(redistribution);

        gatheringNew.mc = mc;

        gatheringNew.isMutable = isMutable;

        gatheringNew.focalizer = msg.sender;

        gatheringCounter++;

        emit CreateGathering(
            gatheringID,
            msg.sender,
            mc,
            collection,
            redistribution,
            isMutable
        );
    }

    function createCeremony(
        uint256 gatheringID
    ) external onlyMC(gatheringID) returns (
        uint256 ceremonyID
    ) {
        Gathering storage gathering = gatherings[gatheringID];

        ceremonyID = gathering.ceremonyCounter;

        gathering.ceremonyCounter++;

        emit CreateCeremony(gatheringID, ceremonyID);
    }

    function contribute(
        uint256 gatheringID,
        uint256 ceremonyID,
        address tokenAddress,
        uint256 tokenID
    ) external {
        require(this.getCollection(gatheringID) == tokenAddress, "Arcoiris: not a valid token");

        IERC721 token = IERC721(tokenAddress);

        token.safeTransferFrom(msg.sender, address(this), tokenID);

        gatherings[gatheringID].ceremonies[ceremonyID].contributions.push(tokenID);

        gatherings[gatheringID].ceremonies[ceremonyID].contributors.push(msg.sender);
    }

    function contributeBatch(
        uint256 gatheringID,
        uint256 ceremonyID,
        address tokenAddress,
        uint256 amount
    ) external {
        require(this.getCollection(gatheringID) == tokenAddress, "Arcoiris: not a valid token");

        IERC721Enumerable token = IERC721Enumerable(tokenAddress);

        require(token.balanceOf(msg.sender) >= amount, "Arcoiris: not enough tokens");

        // for (uint256 i = 0; i < amount; i++) {
            uint256 tokenID = token.tokenOfOwnerByIndex(msg.sender, 0);

            token.safeTransferFrom(msg.sender, address(this), tokenID);

            gatherings[gatheringID].ceremonies[ceremonyID].contributions.push(tokenID);
        // }

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
