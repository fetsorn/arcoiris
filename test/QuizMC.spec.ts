import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  abi as ERC721ABI,
  bytecode as ERC721Bytecode,
} from "@openzeppelin/contracts/build/contracts/ERC721PresetMinterPauserAutoId.json";
import {
  ERC721PresetMinterPauserAutoId,
  Arcoiris,
  IRedistribution,
  QuizMC
} from "~/typechain-types"

describe("Calibrator-js", () => {
    async function quizMCFixture() {
        const [wallet, other, alice, bob] = await ethers.getSigners();

        const tokenFactory = await ethers.getContractFactory(ERC721ABI, ERC721Bytecode);

        const token = (await tokenFactory.deploy(
            "Ticket",
            "TICKT",
            "https://example.com"
        )) as ERC721PresetMinterPauserAutoId;

        const arcoiris = (await ethers
            .getContractFactory("Arcoiris")
            .then((contract) =>
                contract.deploy()
                 )) as Arcoiris;

        const even = (await ethers
            .getContractFactory("Even")
            .then((contract) =>
                contract.deploy()
                 )) as IRedistribution;

        const proportional = (await ethers
            .getContractFactory("Proportional")
            .then((contract) =>
                contract.deploy()
                 )) as IRedistribution;

        const quizMC = (await ethers
            .getContractFactory("QuizMC")
            .then((contract) =>
                contract.deploy(arcoiris.target)
                 )) as QuizMC;

        return {
            wallet,
            other,
            alice,
            bob,
            token,
            arcoiris,
            proportional,
            quizMC
        };
    }

    describe("#completeQuiz", () => {
        it("passes checks", async () => {
            const {
                wallet,
                other,
                alice,
                bob,
                token,
                arcoiris,
                proportional,
                quizMC
            } = await loadFixture(quizMCFixture);

            const txGathering = await arcoiris.createGathering(
                token.target,
                proportional.target,
                quizMC.target,
                false
            );

            const receiptGathering = await txGathering.wait();

            const gatheringID = receiptGathering.logs[0].topics[1];

            const txQuiz = await quizMC.createQuiz(gatheringID);

            const receiptQuiz = await txQuiz.wait();

            const quizID = receiptQuiz.logs[0].topics[1];

            const ceremonyID = await quizMC.getCeremonyID(quizID);

            const txMintAlice = await token.mint(alice.address);

            const receiptMintAlice = await txMintAlice.wait();

            const tokenAlice = receiptMintAlice.logs[0].topics[3];

            const txMintBob = await token.mint(bob.address);

            const receiptMintBob = await txMintBob.wait();

            const tokenBob = receiptMintBob.logs[0].topics[3];

            const txApproveAlice = await token
                .connect(alice)
                .approve(arcoiris.target, tokenAlice);

            await txApproveAlice.wait();

            const txApproveBob = await token
                .connect(bob)
                .approve(arcoiris.target, tokenBob);

            await txApproveBob.wait();

            const txContributeAlice = await arcoiris
                .connect(alice)
                .contribute(
                    gatheringID,
                    ceremonyID,
                    token.target,
                    tokenAlice
                );

            await txContributeAlice.wait();

            const txContributeBob = await arcoiris
                .connect(bob)
                .contribute(
                    gatheringID,
                    ceremonyID,
                    token.target,
                    tokenBob
                );

            await txContributeBob.wait();

            function hashValue(value, salt) {
                const bytes = ethers.toUtf8Bytes(value);

                const guess = ethers.concat([bytes, salt]);

                const hash = ethers.keccak256(guess);

                return hash;
            }

            const saltCorrect = ethers.id("randomnumber");

            const saltHashCorrect = ethers.keccak256(saltCorrect);

            const hashesCorrect = [
                hashValue("banana", saltCorrect),
                hashValue("knife", saltCorrect)
            ];

            await quizMC.commitCorrect(quizID, saltHashCorrect, hashesCorrect);

            const saltAlice = ethers.id("alicenumber");

            const saltHashAlice = ethers.keccak256(saltAlice);

            const hashesAlice = [
                hashValue("banana", saltAlice),
                hashValue("knife", saltAlice)
            ];

            await quizMC.connect(alice).commitGuess(quizID, saltHashAlice, hashesAlice);

            const guessesCorrect = [
                ethers.toUtf8Bytes("banana"),
                ethers.toUtf8Bytes("knife")
            ];

            await quizMC.endQuiz(quizID);

            await quizMC.revealCorrect(quizID, saltCorrect, guessesCorrect);

            await quizMC.connect(alice).revealGuess(quizID, saltAlice, guessesCorrect);

            await quizMC.redistribute(quizID);

            const balanceAlice = await token.balanceOf(alice.address);

            expect(balanceAlice).to.equal(2);
        })
    })
})
