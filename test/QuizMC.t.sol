pragma solidity 0.8.19;

import {Test, Vm} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC721PresetMinterPauserAutoId} from "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import {Arcoiris} from "contracts/Arcoiris.sol";
import {Proportional} from "contracts/redistributions/Proportional.sol";
import {IRedistribution, Mission} from "contracts/interfaces/IRedistribution.sol";
import {QuizMC} from "contracts/mcs/QuizMC.sol";

contract ArcoirisTestHarness is Arcoiris {}

contract CalibratorTest is Test {
    ArcoirisTestHarness arcoiris;
    ERC721PresetMinterPauserAutoId token;
    QuizMC quiz;
    address addressAlice = address(1);
    address addressBob = address(2);
    uint256 tokenAlice;
    uint256 tokenBob;
    uint256 gatheringID;
    uint256 ceremonyID;
    uint256 quizID;

    function setUp() public {
        arcoiris = new ArcoirisTestHarness();

        quiz = new QuizMC(address(arcoiris));

        token = new ERC721PresetMinterPauserAutoId(
            "Base",
            "BASE",
            "https://example.com"
        );

        IRedistribution redistribution = new Proportional();

        gatheringID = arcoiris.createGathering(
            address(token),
            address(redistribution),
            address(quiz),
            false
        );

        quizID = quiz.createQuiz(gatheringID);

        ceremonyID = quiz.getCeremonyID(quizID);

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
    }

    function test_commitCorrect() public {
        bytes32 salt = keccak256("randomnumber");

        bytes32[] memory hashes = new bytes32[](2);
        hashes[0] = keccak256(bytes.concat("banana", salt));
        hashes[1] = keccak256(bytes.concat("knife", salt));

        quiz.commitCorrect(quizID, hashes);

        assertEq(quizID, 0);
    }

    function test_commitGuess() public {
        bytes32 saltCorrect = keccak256("randomnumber");

        bytes32[] memory hashesCorrect = new bytes32[](2);
        hashesCorrect[0] = keccak256(bytes.concat("banana", saltCorrect));
        hashesCorrect[1] = keccak256(bytes.concat("knife", saltCorrect));

        quiz.commitCorrect(quizID, hashesCorrect);

        bytes32 saltAlice = keccak256("alicenumber");

        bytes32[] memory hashesAlice = new bytes32[](2);
        hashesAlice[0] = keccak256(bytes.concat("banana", saltAlice));
        hashesAlice[1] = keccak256(bytes.concat("knife", saltAlice));

        vm.prank(addressAlice);

        quiz.commitGuess(quizID, hashesAlice);
    }

    function test_revealCorrect() public {
        bytes32 saltCorrect = keccak256("randomnumber");

        bytes32[] memory hashesCorrect = new bytes32[](2);
        hashesCorrect[0] = keccak256(bytes.concat("banana", saltCorrect));
        hashesCorrect[1] = keccak256(bytes.concat("knife", saltCorrect));

        quiz.commitCorrect(quizID, hashesCorrect);

        bytes32 saltAlice = keccak256("alicenumber");

        bytes32[] memory hashesAlice = new bytes32[](2);
        hashesAlice[0] = keccak256(bytes.concat("banana", saltAlice));
        hashesAlice[1] = keccak256(bytes.concat("knife", saltAlice));

        vm.prank(addressAlice);

        quiz.commitGuess(quizID, hashesAlice);

        bytes[] memory guessesCorrect = new bytes[](2);
        guessesCorrect[0] = bytes("banana");
        guessesCorrect[1] = bytes("knife");

        quiz.revealCorrect(quizID, saltCorrect, guessesCorrect);

        assertEq(quizID, 0);
    }

    function test_revealGuess() public {
        bytes32 saltCorrect = keccak256("randomnumber");

        bytes32[] memory hashesCorrect = new bytes32[](2);
        hashesCorrect[0] = keccak256(bytes.concat("banana", saltCorrect));
        hashesCorrect[1] = keccak256(bytes.concat("knife", saltCorrect));

        quiz.commitCorrect(quizID, hashesCorrect);

        bytes32 saltAlice = keccak256("alicenumber");

        bytes32[] memory hashesAlice = new bytes32[](2);
        hashesAlice[0] = keccak256(bytes.concat("banana", saltAlice));
        hashesAlice[1] = keccak256(bytes.concat("knife", saltAlice));

        vm.prank(addressAlice);

        quiz.commitGuess(quizID, hashesAlice);

        bytes[] memory guessesAlice = new bytes[](2);
        guessesAlice[0] = bytes("banana");
        guessesAlice[1] = bytes("knife");

        vm.prank(addressAlice);

        quiz.revealGuess(quizID, saltAlice, guessesAlice);
    }

    function test_completeQuiz() public {
        bytes32 saltCorrect = keccak256("randomnumber");

        bytes32[] memory hashesCorrect = new bytes32[](2);
        hashesCorrect[0] = keccak256(bytes.concat(bytes("banana"), saltCorrect));
        hashesCorrect[1] = keccak256(bytes.concat(bytes("knife"), saltCorrect));

        quiz.commitCorrect(quizID, hashesCorrect);

        bytes32 saltAlice = keccak256("alicenumber");

        bytes32[] memory hashesAlice = new bytes32[](2);
        hashesAlice[0] = keccak256(bytes.concat(bytes("banana"), saltAlice));
        hashesAlice[1] = keccak256(bytes.concat(bytes("knife"), saltAlice));

        vm.prank(addressAlice);

        quiz.commitGuess(quizID, hashesAlice);

        bytes[] memory guessesCorrect = new bytes[](2);
        guessesCorrect[0] = bytes("banana");
        guessesCorrect[1] = bytes("knife");

        quiz.revealCorrect(quizID, saltCorrect, guessesCorrect);

        assertEq(quizID, 0);

        bytes[] memory guessesAlice = new bytes[](2);
        guessesAlice[0] = bytes("banana");
        guessesAlice[1] = bytes("knife");

        vm.prank(addressAlice);

        quiz.revealGuess(quizID, saltAlice, guessesAlice);

        quiz.completeQuiz(quizID);

        uint256 balanceAlice = token.balanceOf(addressAlice);

        assertEq(balanceAlice, 2);
    }
}
