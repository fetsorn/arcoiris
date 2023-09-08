// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.8.7 <0.9.0;

import {Arcoiris} from "../Arcoiris.sol";
import {Mission} from "../interfaces/IRedistribution.sol";

/// @title Hosts redistribution ceremonies according to a quiz
/// @author Anton Davydov
contract QuizMC {
    /// @notice Emits when a new quiz is created
    /// @param quizID The index of the new quiz
    /// @param gatheringID The index of the gathering
    /// @param ceremonyID The index of the ceremony
    /// @param moderator The organizer of the quiz
    event CreateQuiz(
        uint256 indexed quizID,
        uint256 indexed gatheringID,
        uint256 indexed ceremonyID,
        address moderator
    );

    /// @notice Emits when the collection ends and guessing begins
    /// @param quizID The index of the quiz
    /// @param hashes Array of guess hashes
    event CommitCorrect(uint256 indexed quizID, bytes32[] hashes);

    /// @notice Emits when quiz ends and answers are revealed
    /// @param quizID The index of the quiz
    /// @param salt Random uuid salt
    /// @param guesses Array of guesses
    event RevealCorrect(uint256 indexed quizID, bytes32 indexed salt, bytes[] guesses);

    /// @notice Emits when player submits hashes of guesses
    /// @param quizID The index of the quiz
    /// @param player The address of the player
    /// @param hashes Hashes of guesses
    event CommitGuess(uint256 indexed quizID, address indexed player, bytes32[] hashes);

    /// @notice Emits when player submits hashes of guesses
    /// @param quizID The index of the quiz
    /// @param player The address of the player
    /// @param salt Random uuid salt
    /// @param guesses Guesses
    event RevealGuess(uint256 indexed quizID, address indexed player, bytes32 indexed salt, bytes[] guesses);

    /// @notice Emits when the guessing ends and wealth is redistributed
    /// @param quizID The index of the quiz
    event CompleteQuiz(uint256 indexed quizID);

    /// @notice Only allows functions if msg.sender is the organizer of the quiz
    modifier onlyModerator(uint256 quizID) {
        require(
            msg.sender == quizzes[quizID].moderator,
            "Only moderator can call this function."
        );
        _;
    }

    /// @notice Information about a quiz
    struct Quiz {
        uint256 gatheringID;
        uint256 ceremonyID;
        address moderator;
        bytes32[] hashesCorrect;
        bytes[] guessesCorrect;
        bytes32 saltCorrect;
        bytes32 saltHashCorrect;
        mapping(address => bool) isEligiblePlayer;
        address[] players;
        mapping(address => bool) hasCommitted;
        mapping(address => bool) hasRevealed;
        mapping(address => bytes[]) guesses;
        mapping(address => bytes32[]) hashes;
        mapping(address => bytes32) salts;
        mapping(address => bytes32) saltHashes;
        mapping(address => uint256) points;
    }

    /// @notice Version of the contract, bumped on each deployment
    string public constant VERSION = "0.0.2";

    /// @notice The Arcoíris contract
    Arcoiris arcoiris;

    /// @notice The number of created quizzes
    uint256 public quizCounter;

    /// @notice Indexed map of quiz structs
    mapping(uint256 => Quiz) internal quizzes;

    constructor(address _arcoiris) {
        arcoiris = Arcoiris(_arcoiris);
    }

    /// @notice Get ID of the gathering associated with a quiz
    /// @param quizID The index of a quiz
    /// @return gatheringID The index of a gathering
    function getGatheringID(
        uint256 quizID
    ) external view returns (uint256 gatheringID) {
        return quizzes[quizID].gatheringID;
    }

    /// @notice Get ID of the ceremony associated with a quiz
    /// @param quizID The index of a quiz
    /// @return ceremonyID The index of a ceremony
    function getCeremonyID(
        uint256 quizID
    ) external view returns (uint256 ceremonyID) {
        return quizzes[quizID].ceremonyID;
    }

    /// @notice Create a quiz and a redistribution ceremony
    /// @param gatheringID The index of the gathering
    /// @return quizID The index of the new quiz
    function createQuiz(uint256 gatheringID) external returns (uint256 quizID) {
        require(
            arcoiris.getMC(gatheringID) == address(this),
            "Quiz: is not MC"
        );

        quizID = quizCounter;

        quizzes[quizID].moderator = msg.sender;

        quizzes[quizID].gatheringID = gatheringID;

        uint256 ceremonyID = arcoiris.createCeremony(gatheringID);

        quizzes[quizID].ceremonyID = ceremonyID;

        quizCounter++;

        emit CreateQuiz(quizID, gatheringID, ceremonyID, msg.sender);
    }

    /// @notice End collection, commit to answers and start accepting guesses
    /// @param quizID The index of the quiz
    /// @param hashes Array of guess hashes
    function commitCorrect(uint256 quizID, bytes32 saltHash, bytes32[] memory hashes) external onlyModerator(quizID) {
        arcoiris.endCollection(
            quizzes[quizID].gatheringID,
            quizzes[quizID].ceremonyID
        );

        address[] memory contributors = arcoiris.getContributors(
            quizzes[quizID].gatheringID,
            quizzes[quizID].ceremonyID
        );

        for (uint256 i = 0; i < contributors.length; i++) {
            quizzes[quizID].isEligiblePlayer[contributors[i]] = true;
        }

        quizzes[quizID].saltHashCorrect = saltHash;

        for (uint256 i = 0; i < hashes.length; i++) {
            quizzes[quizID].hashesCorrect.push(hashes[i]);
        }


        emit CommitCorrect(quizID, hashes);
    }

    /// @notice End collection and start accepting guesses
    /// @param quizID The index of the quiz
    /// @param salt Random uuid salt
    /// @param guesses Array of guesses
    function revealCorrect(uint256 quizID, bytes32 salt, bytes[] memory guesses) external onlyModerator(quizID) {
        quizzes[quizID].saltCorrect = salt;

        for (uint256 i = 0; i < guesses.length; i++) {
            quizzes[quizID].guessesCorrect.push(guesses[i]);
        }

        emit RevealCorrect(quizID, salt, guesses);
    }

    /// @notice Place a guess for priority of each ceremony member
    /// @param quizID The index of the quiz
    /// @param hashes Hashes of guesses
    function commitGuess(uint256 quizID, bytes32 saltHash, bytes32[] memory hashes) external {
        require(
            quizzes[quizID].isEligiblePlayer[msg.sender],
            "Quiz: player is not eligible"
        );

        require(
            !quizzes[quizID].hasCommitted[msg.sender],
            "Quiz: player has already guessed"
        );

        quizzes[quizID].saltHashes[msg.sender] = saltHash;

        for (uint256 i = 0; i < hashes.length; i++) {
            quizzes[quizID].hashes[msg.sender].push(hashes[i]);
        }

        quizzes[quizID].players.push(msg.sender);

        quizzes[quizID].hasCommitted[msg.sender] = true;

        emit CommitGuess(quizID, msg.sender, hashes);
    }

    function revealGuess(uint256 quizID, bytes32 salt, bytes[] memory guesses) external {
        require(
            quizzes[quizID].isEligiblePlayer[msg.sender],
            "Quiz: player is not eligible"
        );

        require(
            !quizzes[quizID].hasRevealed[msg.sender],
            "Quiz: player has already revealed"
        );

        quizzes[quizID].salts[msg.sender] = salt;

        for (uint256 i = 0; i < guesses.length; i++) {
            quizzes[quizID].guesses[msg.sender].push(guesses[i]);
        }

        quizzes[quizID].players.push(msg.sender);

        quizzes[quizID].hasRevealed[msg.sender] = true;

        emit RevealGuess(quizID, msg.sender, salt, guesses);
    }

    /// @notice Redistribute wealth according to guessing results
    /// @param quizID The index of the quiz
    function completeQuiz(uint256 quizID) external onlyModerator(quizID) {
        require(quizzes[quizID].saltHashCorrect == keccak256(bytes.concat(quizzes[quizID].saltCorrect)));

        for (uint256 i = 0; i < quizzes[quizID].hashesCorrect.length; i++) {
            bytes memory guess = bytes.concat(
                quizzes[quizID].guessesCorrect[i],
                quizzes[quizID].saltCorrect
            );

            bytes32 hash = keccak256(guess);

            require(hash == quizzes[quizID].hashesCorrect[i], "QuizMC: correct invalid");
        }

        for (uint256 i = 0; i < quizzes[quizID].players.length; i++) {
            address player = quizzes[quizID].players[i];

            require(quizzes[quizID].saltHashes[player] == keccak256(bytes.concat(quizzes[quizID].salts[player])));

            for (uint256 j = 0; j < quizzes[quizID].hashesCorrect.length; j++) {

                bytes memory guess = bytes.concat(
                    quizzes[quizID].guesses[player][j],
                    quizzes[quizID].salts[player]
                );

                bytes32 hash = keccak256(guess);

                require(hash == quizzes[quizID].hashes[player][j], "QuizMC: guess invalid");

                if (keccak256(quizzes[quizID].guesses[player][j]) ==
                    keccak256(quizzes[quizID].guessesCorrect[j])) {
                    quizzes[quizID].points[player]++;
                }
            }
        }

        address[] memory siblings = arcoiris.getContributors(
            quizzes[quizID].gatheringID,
            quizzes[quizID].ceremonyID
        );

        uint256[] memory priorities = new uint256[](siblings.length);

        for (uint256 i = 0; i < siblings.length; i++) {
            priorities[i] = quizzes[quizID].points[siblings[i]];
        }

        emit CompleteQuiz(quizID);

        arcoiris.redistribute(
            quizzes[quizID].gatheringID,
            quizzes[quizID].ceremonyID,
            siblings,
            priorities
        );
    }
}
