pragma solidity 0.8.19;

import {Test, Vm} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC721PresetMinterPauserAutoId} from "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Proportional} from "contracts/redistributions/Proportional.sol";
import {IRedistribution, Mission} from "contracts/interfaces/IRedistribution.sol";
import {VotingMC} from "contracts/mcs/VotingMC.sol";

contract ArcoirisTestHarness is Arcoiris {}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;
    ERC721PresetMinterPauserAutoId token;
    VotingMC poll;
    address addressAlice = address(1);
    address addressBob = address(2);
    uint256 tokenAlice;
    uint256 tokenBob;
    uint256 gatheringID;
    uint256 ceremonyID;
    uint256 pollID;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();

        poll = new VotingMC(address(arcoiris));

        token = new ERC721PresetMinterPauserAutoId(
            "Base",
            "BASE",
            "https://example.com"
        );

        IRedistribution redistribution = new Proportional();

        gatheringID = arcoiris.createGathering(
            address(token),
            address(redistribution),
            address(poll),
            false
        );

        pollID = poll.createPoll(gatheringID);

        ceremonyID = poll.getCeremonyID(pollID);

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

        poll.endCollection(pollID);
    }

    function test_commencePoll() public {
        address[] memory voters = new address[](2);
        voters[0] = addressAlice;
        voters[1] = addressBob;

        poll.commencePoll(pollID);

        assertEq(pollID, 0);
    }

    function test_vote() public {
        address[] memory voters = new address[](2);
        voters[0] = addressAlice;
        voters[1] = addressBob;

        poll.commencePoll(pollID);

        Mission[] memory votes = new Mission[](2);
        votes[0] = Mission(address(addressAlice), 1);
        votes[1] = Mission(address(addressBob), 0);

        vm.prank(addressAlice);

        poll.vote(pollID, votes);
    }

    function test_completePoll() public {
        address[] memory voters = new address[](2);
        voters[0] = addressAlice;
        voters[1] = addressBob;

        poll.commencePoll(pollID);

        Mission[] memory votes = new Mission[](2);
        votes[0] = Mission(address(addressAlice), 1);
        votes[1] = Mission(address(addressBob), 0);

        vm.prank(addressAlice);

        poll.vote(pollID, votes);

        vm.prank(addressBob);

        poll.vote(pollID, votes);

        poll.completePoll(pollID);

        uint256 balanceAlice = token.balanceOf(addressAlice);

        assertEq(balanceAlice, 2);
    }
}
