import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@xyrusworx/hardhat-solidity-json";
import 'solidity-coverage';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
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
