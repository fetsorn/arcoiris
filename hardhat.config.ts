import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "@xyrusworx/hardhat-solidity-json";
import "hardhat-abi-exporter";
import 'solidity-coverage';

import { config } from "dotenv";

config();

const {
  PRIVATE_KEY,
} = process.env;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    gton: {
      url: "https://rpc.gton.network",
      accounts: [PRIVATE_KEY],
    },
    gtonTestnet: {
      url: "https://testnet.gton.network",
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com",
      accounts: [PRIVATE_KEY],
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          // viaIR: true,
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  abiExporter: {
    clear: true,
    flat: true,
    spacing: 2,
  },
  mocha: {
    timeout: "100000000000000",
  }
}
