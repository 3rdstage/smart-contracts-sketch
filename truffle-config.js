// https://github.com/trufflesuite/truffle/tree/v5.1.5/packages/hdwallet-provider
// https://web3js.readthedocs.io/en/v1.3.0/web3.html#providers
// https://iancoleman.io/bip39/
const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3HttpProvider = require('web3-providers-http');
const Web3WsProvider = require('web3-providers-ws');

// Read properties for local standalone Ganache CLI node
const fs = require('fs');
const config = fs.readFileSync('scripts/ganache-cli.properties').toString();
const ganache = {
  host : config.match(/ethereum.host=.*/g)[0].substring(14),
  port : config.match(/ethereum.port=[0-9]*/g)[0].substring(14),
  net : config.match(/ethereum.netVersion=[0-9]*/g)[0].substring(20),
  websocket: false
}

// https://www.npmjs.com/package/web3-providers-http
const httpOptions = {
  keepAlive: true, timeout: 70000
}

// https://www.npmjs.com/package/web3-providers-ws
const wsOptions = {
  timeout: 600000,

  clientConfig: {
    maxReceivedFrameSize: 100000000,
    maxReceivedMessageSize: 100000000,

    keepalive: true,
    keepaliveInterval: 60000,
  },

  reconnect: { auto: true, delay: 5000, maxAttempts: 5, onTimeout: false }
}


// http://truffleframework.com/docs/advanced/configuration
// https://infura.io/docs/gettingStarted/chooseaNetwork
// https://ethereum.stackexchange.com/questions/27048/comparison-of-the-different-testnets
module.exports = {
  
  contracts_build_directory: "./build/truffle",  // default: ./build/contracts

  networks: {
    
    // https://www.trufflesuite.com/docs/truffle/reference/choosing-an-ethereum-client#truffle-develop
    builtin: {    // truffle built-in client : aka `truffle develop`
      host: '127.0.0.1',
      port: 9545,
      network_id: "*"
    },
    
    development: {
      host: ganache.host,
      port: ganache.port,
      network_id: ganache.net,
      gas: 3E8,
      gasPrice: 0,
      websockets: ganache.websocket
    },
    
    mainnet: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC, "https://mainnet.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '1'      
    },

    //Ropsten : PoW
    //GitHub : https://github.com/ethereum/ropsten/
    //Explorer : https://ropsten.etherscan.io/
    //Faucet : https://faucet.ropsten.be/
    ropsten: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC, "https://ropsten.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '3',
      gas: 7E6,
      gasPrice: 1E10
    },

    //Rinkeby : PoA
    //Explorer : https://rinkeby.etherscan.io/
    //Faucet : https://faucet.rinkeby.io/
    //Avg. Block Time : 15s
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.BIP39_MNEMONIC, "https://rinkeby.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '4',
    },

    //Kovan : PoA
    //GitHub : https://github.com/kovan-testnet/
    //Explorer : https://kovan.etherscan.io/
    //Faucet : https://github.com/kovan-testnet/faucet
    //Avg. Block Time : 4s
    kovan: {
      provider: () => 
        new HDWalletProvider({
          mnemonic: process.env.BIP39_MNEMONIC,
          providerOrUrl: new Web3HttpProvider("https://kovan.infura.io/v3/" + process.env.INFURA_PROJECT_ID, httpOptions),
          pollingInterval: 2000
        }),
      network_id: '42', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      //gas: 7E6,
      //gasPrice: 5E10
    },
    
    kovan_ws: {
      provider: () => 
        new HDWalletProvider({
          mnemonic: process.env.BIP39_MNEMONIC,
          providerOrUrl: new Web3WsProvider("wss://kovan.infura.io/ws/v3/" + process.env.INFURA_PROJECT_ID, wsOptions),
          pollingInterval: 2000
        }),
      network_id: '42', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      websockets: true, 
      //gas: 7E6,
      //gasPrice: 5E10

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
  // https://solidity.readthedocs.io/en/v0.6.6/using-the-compiler.html#target-options
  compilers: {
    solc: {
      version: "pragma",  // https://github.com/trufflesuite/truffle/releases/tag/v5.2.0
      //parser: "solcjs",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        },
        evmVersion: "istanbul"  // berlin, istanbul, petersburg, constantinople, byzantium
      }
    },
  },
};
