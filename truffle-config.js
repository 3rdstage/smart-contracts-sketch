// https://github.com/trufflesuite/truffle/tree/v5.1.5/packages/hdwallet-provider
// https://web3js.readthedocs.io/en/v1.3.0/web3.html#providers
// https://infura.io/docs/ethereum#section/Choose-a-Network
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
      websockets: ganache.websocket,
      skipDryRun: true
    },
    
    mainnet: {
      provider: () => new HDWalletProvider(
        process.env.BIP39_MNEMONIC,
        "https://mainnet.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '1',
      skipDryRun: true
    },

    //Ropsten : PoW
    //GitHub : https://github.com/ethereum/ropsten/
    //Explorer : https://ropsten.etherscan.io/
    //Faucet : https://faucet.ropsten.be/
    ropsten: {
      provider: () => new HDWalletProvider(
        process.env.BIP39_MNEMONIC,
        "https://ropsten.infura.io/v3/" + process.env.INFURA_PROJECT_ID),
      network_id: '3',
      gas: 7E6,
      gasPrice: 1E10,
      skipDryRun: true
    },

    //Rinkeby : PoA
    //Explorer : https://rinkeby.etherscan.io/
    //Faucet : https://faucet.rinkeby.io/
    //Avg. Block Time : 15s
    rinkeby: {
      provider: () =>
        new HDWalletProvider({
          chainId: "4",
          mnemonic: process.env.BIP39_MNEMONIC,
          providerOrUrl: new Web3HttpProvider(
            "https://rinkeby.infura.io/v3/" + process.env.INFURA_PROJECT_ID, httpOptions),
          pollingInterval: "5500"
        }),
      network_id: "4",
      // gas: 7E6,
      // gasPrice: 1E10,
      skipDryRun: true
    },
    
    rinkeby_ws: {
      provider: () => {
        // Monkey patch to support `web3.eth.subscribe()` function
        // https://github.com/trufflesuite/truffle/issues/2567
        const wsProvider = new Web3WsProvider(
          "wss://rinkeby.infura.io/ws/v3/" + process.env.INFURA_PROJECT_ID, wsOptions);
        HDWalletProvider.prototype.on = wsProvider.on.bind(wsProvider);
        return new HDWalletProvider({
          mnemonic: process.env.BIP39_MNEMONIC,
          providerOrUrl: wsProvider,
          pollingInterval: 5500
        });
      },
      network_id: '4', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      websockets: true,
      skipDryRun: true
    },

    //Kovan : PoA
    //GitHub : https://github.com/kovan-testnet/
    //Explorer : https://kovan.etherscan.io/
    //Faucet : https://github.com/kovan-testnet/faucet
    //Avg. Block Time : 4s
    kovan: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.BIP39_MNEMONIC,
        providerOrUrl: new Web3HttpProvider(
          "https://kovan.infura.io/v3/" + process.env.INFURA_PROJECT_ID, httpOptions),
        pollingInterval: 2000
      }),
      network_id: '42', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      //gas: 7E6,
      //gasPrice: 5E10,
      skipDryRun: true
    },
    
    kovan_ws: {
      provider: () => {
        // Monkey patch to support `web3.eth.subscribe()` function
        // https://github.com/trufflesuite/truffle/issues/2567
        const wsProvider = new Web3WsProvider(
          "wss://kovan.infura.io/ws/v3/" + process.env.INFURA_PROJECT_ID, wsOptions);
        HDWalletProvider.prototype.on = wsProvider.on.bind(wsProvider);
        return new HDWalletProvider({
          mnemonic: process.env.BIP39_MNEMONIC,
          providerOrUrl: wsProvider,
          pollingInterval: 2000
        });
      },
      network_id: '42', //https://github.com/ethereum/wiki/wiki/JSON-RPC#net_version
      //gas: 7E6,
      //gasPrice: 5E10,
      websockets: true,
      skipDryRun: true
    },

    // Goerli : PoA
    // GitHub : https://github.com/goerli/testnet
    // Explorer : https://goerli.etherscan.io/
    // Faucet :
    // Avg. Block Time : 15s
    goerli: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.BIP39_MNEMONIC,
        providerOrUrl: new Web3HttpProvider(
          "https://goerli.infura.io/v3/" + process.env.INFURA_PROJECT_ID, httpOptions),
        pollingInterval: 15000
      }),
      network_id: '5',
      skipDryRun: true
    },
    
    // Klaytn Testnet
    baobab: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.BIP39_MNEMONIC,
        providerOrUrl: new Web3HttpProvider(
          "https://api.baobab.klaytn.net:8651/", httpOptions),
        pollingInterval: 2000
      }),
      network_id: '1001',
      skipDryRun: true
    },
    
    // Binance Smart Chain Testnet
    // https://docs.binance.org/smart-chain/developer/deploy/truffle.html
    // GitHub :
    // Explorer : https://testnet.bscscan.com/
    // Faucet : https://testnet.binance.org/faucet-smart
    // Avg. Block Time : 3s
    bsc_test: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.BIP39_MNEMONIC,
        providerOrUrl: new Web3HttpProvider("https://data-seed-prebsc-1-s1.binance.org:8545", httpOptions),
        pollingInterval: 3500
      }),
      network_id: '97',
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    
  },

  // https://github.com/mochajs/mocha/blob/v8.1.2/lib/mocha.js#L97
  // https://mochajs.org/#command-line-usage
  // https://mochajs.org/api/mocha
  mocha: {
    color: true,
    //useColor: true,
    fullTrace: true,
    noHighlighting: false,
    //enableTimeouts: true,
    timeout: 180000,
    parallel: false
  },

  // https://trufflesuite.com/docs/truffle/reference/configuration.html
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
