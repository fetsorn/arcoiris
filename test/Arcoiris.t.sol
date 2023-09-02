pragma solidity 0.8.19;

import {Test, Vm} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC721PresetMinterPauserAutoId} from "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Proportional} from "contracts/redistributions/Proportional.sol";
import {IRedistribution} from "contracts/interfaces/IRedistribution.sol";

contract ArcoirisTestHarness is Arcoiris {}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;
    ERC721PresetMinterPauserAutoId token;
    address addressAlice = address(1);
    address addressBob = address(2);
    address addressMC = address(3);
    uint256 tokenAlice;
    uint256 tokenBob;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();

        token = new ERC721PresetMinterPauserAutoId(
            "Base",
            "BASE",
            "https://example.com"
        );

        // mint token to Alice

        vm.recordLogs();

        token.mint(addressAlice);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        tokenAlice = uint256(entries[0].topics[3]);

        // mint token to Bob

        vm.recordLogs();

        token.mint(addressBob);

        entries = vm.getRecordedLogs();

        tokenBob = uint256(entries[0].topics[3]);
    }

    function createGathering() public returns (uint256) {
        IRedistribution redistribution = new Proportional();

        uint256 gatheringID = arcoiris.createGathering(
            address(token),
            address(redistribution),
            addressMC,
            false
        );

        return gatheringID;
    }

    function createCeremony() public returns (uint256, uint256) {
        uint256 gatheringID = createGathering();

        vm.prank(addressMC);

        uint256 ceremonyID = arcoiris.createCeremony(gatheringID);

        return (gatheringID, ceremonyID);
    }

    function test_createGathering() public {
        uint256 gatheringID = createGathering();

        assertEq(gatheringID, 0);
    }

    function test_createCeremony() public {
        uint256 gatheringID;
        uint256 ceremonyID;

        (gatheringID, ceremonyID) = createCeremony();

        assertEq(ceremonyID, 0);
    }

    function includes(
        address[] memory array,
        address element
    ) public pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }

        return false;
    }

    function test_contribute() public {
        uint256 gatheringID;
        uint256 ceremonyID;

        (gatheringID, ceremonyID) = createCeremony();

        // alice contributes

        vm.prank(addressAlice);

        token.approve(address(arcoiris), tokenAlice);

        vm.prank(addressAlice);

        arcoiris.contribute(
            gatheringID,
            ceremonyID,
            address(token),
            tokenAlice
        );

        // alice becomes a contributor

        address[] memory contributors = arcoiris.getContributors(
            gatheringID,
            ceremonyID
        );

        assertEq(includes(contributors, addressAlice), true);
    }

    function test_endCollection() public {
        uint256 gatheringID;
        uint256 ceremonyID;

        (gatheringID, ceremonyID) = createCeremony();

        vm.prank(addressMC);

        arcoiris.endCollection(gatheringID, ceremonyID);

        assertEq(arcoiris.getIsCollectionEnded(gatheringID, ceremonyID), true);
    }

    function test_redistribute() public {
        uint256 gatheringID;
        uint256 ceremonyID;

        (gatheringID, ceremonyID) = createCeremony();

        // alice contributes

        uint256 balanceAlice = token.balanceOf(addressAlice);

        assertEq(balanceAlice, 1);

        vm.prank(addressAlice);

        token.approve(address(arcoiris), tokenAlice);

        vm.prank(addressAlice);

        arcoiris.contribute(
            gatheringID,
            ceremonyID,
            address(token),
            tokenAlice
        );

        balanceAlice = token.balanceOf(addressAlice);

        assertEq(balanceAlice, 0);

        // bob contributes

        uint256 balanceBob = token.balanceOf(addressBob);

        assertEq(balanceBob, 1);

        vm.prank(addressBob);

        token.approve(address(arcoiris), tokenBob);

        vm.prank(addressBob);

        arcoiris.contribute(gatheringID, ceremonyID, address(token), tokenBob);

        balanceBob = token.balanceOf(addressBob);

        assertEq(balanceBob, 0);

        // mc ends collection

        vm.prank(addressMC);

        arcoiris.endCollection(gatheringID, ceremonyID);

        // mc redistributes

        address[] memory siblings = new address[](1);
        siblings[0] = addressAlice;

        uint256[] memory priorities = new uint256[](1);
        priorities[0] = 1;

        vm.prank(addressMC);

        arcoiris.redistribute(gatheringID, ceremonyID, siblings, priorities);

        // alice receives all shares

        balanceAlice = token.balanceOf(addressAlice);

        assertEq(balanceAlice, 2);
    }
}
