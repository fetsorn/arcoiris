import { ethers } from "hardhat";
import { BigNumber } from "ethers";
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

import { expandTo18Decimals } from "./utilities"

interface TokenFixture {
  token: ERC721PresetMinterPauserAutoId
}

export const tokenFixture = async function (
  [wallet, other],
  provider
): Promise<TokenFixture> {
  const tokenFactory = await ethers.getContractFactory(ERC721ABI, ERC721Bytecode);

  const token = (await tokenFactory.deploy(
    "Ticket",
    "TICKT",
    "https://example.com"
  )) as ERC721PresetMinterPauserAutoId;

  return { token };
}

interface ArcoirisFixture extends TokenFixture {
  arcoiris: Arcoiris
  proportional: IRedistribution
  even: IRedistribution
}

export const arcoirisFixture = async function (
  [wallet, other],
  provider
): Promise<ArcoirisFixture> {
  const { token } = await tokenFixture(
    [wallet, other],
    provider
  );

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

  return {
    token,
    arcoiris,
    even,
    proportional
  };
}

interface QuizMCFixture extends ArcoirisFixture {
  quizMC: QuizMC
}

export const quizMCFixture = async function (
  [wallet, other],
  provider
): Promise<QuizMCFixture> {
  const {
    token,
    arcoiris,
    even,
    proportional
  } = await arcoirisFixture([wallet, other], provider);

  const quizMC = (await ethers
    .getContractFactory("QuizMC")
    .then((contract) =>
      contract.deploy(arcoiris.address)
    )) as QuizMC;

  return {
    token,
    arcoiris,
    proportional,
    quizMC
  };
}
