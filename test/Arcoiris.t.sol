pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Even} from "contracts/redistributions/Even.sol";

contract ArcoirisTestHarness is Arcoiris {}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();
        // TODO: token deploy
        // TODO: alice topup
        // TODO: bob topup
        // TODO: tony topup
    }

    function createGathering() public returns (uint256) {
        Even even = Even(address(0));

        uint256 gatheringID = arcoiris.createGathering(
            address(0),
            even,
            address(msg.sender),
            false
        );

        return gatheringID;
    }

    function createCeremony() public returns (uint256, uint256) {
        uint256 gatheringID = createGathering();

        uint256 ceremonyID = arcoiris.createCeremony(
            gatheringID
        );

        return (gatheringID, ceremonyID);
    }

    function test_createGathering() public {
        uint256 gatheringID = createGathering();

        assertEq(gatheringID, 0);
    }

    function test_createCeremony() public {
        (gatheringID, ceremonyID) = createCeremony();

        assertEq(ceremonyID, 0);
    }

    function test_contribute() public {
        (gatheringID, ceremonyID) = createCeremony();

        // TODO: alice contribute
        arcoiris.contribute(gatheringID, ceremonyID, token, tokenAlice);

        uint256 contributors = arcoiris.getContributors(gatheringID, ceremonyID);

        // TODO: assert contributors include alice
    }

    function test_contribute() public {
        (gatheringID, ceremonyID) = createCeremony();

        uint256 balanceAlice = token.balanceOf(aliceAddress);

        assertEq(balanceAlice, 1);

        // TODO: alice contribute
        arcoiris.contribute(gatheringID, ceremonyID, token, tokenAlice);

        balanceAlice = token.balanceOf(aliceAddress);

        assertEq(balanceAlice, 0);

        uint256 contributors = arcoiris.getContributors(gatheringID, ceremonyID);

        // TODO: assert contributors include alice
    }

    function test_endCollection() public {
        (gatheringID, ceremonyID) = createCeremony();

        // TODO: mc ends collection
        arcoiris.endCollection(gatheringID, ceremonyID);

        assertEq(arcoiris.getIsCollectionComplete(gatheringID, ceremonyID), true);
    }

    function test_redistribute() public {
        (gatheringID, ceremonyID) = createCeremony();

        uint256 balanceAlice = token.balanceOf(aliceAddress);

        assertEq(balanceAlice, 1);

        // TODO: alice contributes
        arcoiris.contribute(gatheringID, ceremonyID, token, tokenAlice);
        //
        // TODO: bob contributes
        arcoiris.contribute(gatheringID, ceremonyID, token, tokenBob);

        // TODO: mc ends collection
        arcoiris.endCollection(gatheringID, ceremonyID);

        // TODO: mc redistributes collection
        arcoiris.redistribute(gatheringID, ceremonyID, [aliceAddress], [1]);

        balanceAlice = token.balanceOf(aliceAddress);

        assertEq(balanceAlice, 2);
    }
}
