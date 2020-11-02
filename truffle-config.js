// https://github.com/trufflesuite/truffle/tree/v5.1.5/packages/hdwallet-provider
// https://iancoleman.io/bip39/
const HDWalletProvider = require("@truffle/hdwallet-provider");

// Read properties for local standalone Ganache CLI node
const fs = require('fs');
const config = fs.readFileSync('scripts/ganache-cli.properties').toString();
const ganache = {
  host : config.match(/ethereum.host=.*/g)[0].substring(14),
  port : config.match(/ethereum.port=[0-9]*/g)[0].substring(14),
  net : config.match(/ethereum.netVersion=[0-9]*/g)[0].substring(20),
  websocket: false
}

// http://truffleframework.com/docs/advanced/configuration
module.exports = {

  networks: {
    development: {
      host: ganache.host,
      port: ganache.port,
      network_id: ganache.net,
      gas: 3E8,
      gasPrice: 0,
      websockets: ganache.websocket
    },

    //GitHub : https://github.com/ethereum/ropsten/
    //Explorer : https://ropsten.etherscan.io/
    //Faucet : https://faucet.ropsten.be/
    ropsten: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC,"https://ropsten.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '3',
      gas: 7E6,
      gasPrice: 1E10
    },

    //Explorer : https://rinkeby.etherscan.io/
    //Faucet : https://faucet.rinkeby.io/
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC, "https://rinkeby.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '4',
    },

    //GitHub : https://github.com/kovan-testnet/
    //Explorer : https://kovan.etherscan.io/
    //Faucet : https://faucet.kovan.network/
    kovan: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC, "https://kovan.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '42', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      gas: 7E6,
      gasPrice: 5E10
    }
  },

  // https://github.com/mochajs/mocha/blob/v5.2.0/lib/mocha.js#L64
  // https://mochajs.org/#command-line-usage
  mocha: {
    useColors: true,
    enableTimeouts: true,
    timeout: 180000
  },

  // http://truffleframework.com/docs/advanced/configuration
  compilers: {
    solc: {
      version: "^0.6.0",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "petersburg"
      }
    },
  },
};
