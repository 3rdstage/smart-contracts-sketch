import {HardhatUserConfig} from "hardhat/config";

// https://hardhat.org/hardhat-runner/docs/config
const config: HardhatUserConfig = {

  paths: {
    artifacts : "./build/hardhat",
    tests: "./hardhat/test",
    cache: "./hardhat/cache"
  },

  // https://www.npmjs.com/package/solc?activeTab=versions
  solidity: {
    compilers: [
      {
        version: "0.8.19"
      },
      {
        version: "0.7.6"
      },
      {
        version: "0.6.12"
      }
    ],
  }

};

export default config;