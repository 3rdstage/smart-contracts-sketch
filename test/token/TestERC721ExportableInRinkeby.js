const Token = artifacts.require("ERC721Exportable");
const testcases = require('./ERC721ExportableTestCases');
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

//References
//Truffle test in JavaScript : https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
//Truffle Contract Guide : https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts
//Truffle Contract Package : https://github.com/trufflesuite/truffle/tree/master/packages/contract
//Mocha Documentation : https://mochajs.org/#getting-started
//Chai Assert API : https://www.chaijs.com/api/assert/
//Chai Expect/Should API : https://www.chaijs.com/api/bdd/
//OpenZeppelin Test Helpers API : https://docs.openzeppelin.com/test-helpers/0.5/api
//web3 API : https://web3js.readthedocs.io/en/v1.2.11/
//chance.js : https://chancejs.com/
//bn.js : https://github.com/indutny/bn.js/
//JavaScript Reference (MDN) : https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference
//The Modern JavaScript Tutorial : http://javascript.info/

// NOTE : This is test for the contract located at `0xFD9f0484568cf275F11bA103f9f814f7FDea38b9` address in Rinkeby
//        deployed by `0xb009cd53957c0D991CAbE184e884258a1D7b77D9` at 2022/03/04
const ADMIN_ADDRESS = '0xb009cd53957c0D991CAbE184e884258a1D7b77D9';
const CONTRACT_ADDRESS = '0xD3951a7C3f9A8b716f368DFd9e4446dAD89b2428';

const factoryFunc = async (admin) => {
  const token = await Token.at(CONTRACT_ADDRESS);
  
  console.debug(`Found deployed contract - name: ${Token.toJSON().contractName}, address: ${token.address}`)
  //console.debug(token);
  return token;
}


"use strict";
contract("ERC721Exportable Contract Test Suite", async accounts => {

  // avoid too many accounts
  //if(accounts.length > 8) accounts = (new Chance()).pickset(accounts, 8);

  const EventNames = {
      Transfer: 'Transfer',
      Approval: 'Approval'
  }
  

  async function createFixtures(){
    const chance = new Chance();
    const admin = ADMIN_ADDRESS;
    const token = await Token.at(CONTRACT_ADDRESS);

    return [chance, admin, token];
  }

  before(async () => {
    const output = [];
    for(const acct of accounts){
      //await web3.eth.personal.unlockAccount(acct); // not working with Rinkeby
      await output.push([acct, await web3.eth.getBalance(acct)]);
    }

    const id = await web3.eth.getChainId();
    assert.equal(id, 4, "This test is only for Rinkeby network. Current network is another one."); // expect Rinkeby
    assert.include(accounts, ADMIN_ADDRESS);
    
    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(output);
  });

  testcases.exportTest(accounts, accounts[0], factoryFunc);
  
});
