
const SolidityTestContract = artifacts.require("SolidityTest");
const Web3TestContract = artifacts.require("Web3TestContract");

module.exports = async function (deployer, network, accounts) {
  'use strict';
  
  await deployer.deploy(SolidityTestContract);
  await deployer.deploy(Web3TestContract);
  
  const logs = [
    {key: 'Target Network', value: network},
    {key: 'Accounts[0]', value: accounts[0]},
    {key: 'SolidityTestContract', value: (await SolidityTestContract.deployed()).address},
    {key: 'Web3TestContract', value: (await Web3TestContract.deployed()).address},
  ]

  console.table(logs);
};