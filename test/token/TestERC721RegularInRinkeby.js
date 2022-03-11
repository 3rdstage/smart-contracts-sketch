const Token = artifacts.require("ERC721Regular");
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

// NOTE : This is test for the contract located at `0xf113B4dc9d145aDa4b1f70d1170B3085eAe28497` address in Rinkeby
//        deployed by `0xb009cd53957c0D991CAbE184e884258a1D7b77D9` at 2022/03/04
const ADMIN_ADDRESS = '0xb009cd53957c0D991CAbE184e884258a1D7b77D9';
const CONTRACT_ADDRESS = '0xf113B4dc9d145aDa4b1f70d1170B3085eAe28497';


"use strict";


contract("ERC721Regular Contract Test Suite", async accounts => {

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
    assert.equal(id, 4); // expect Rinkeby
    assert.include(accounts, ADMIN_ADDRESS)
    
    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(output);
  });

  describe("Mint and burn", () => {

    // name(), symbol(), decimals()
    it("Can mint and burn a token", async() => {
      const [chance, admin, token] = await createFixtures();
      
      const mintee = accounts[1];
      const result = await token.mint(mintee, {from: admin});
      
      assert.isTrue(result.receipt.status);
      assert.equal(result.logs[0].event, EventNames.Transfer);
      
      const id = result.logs.filter(log => log.address == CONTRACT_ADDRESS && log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      // try to burn the right previously minted token
      const result2 = await token.burn(8, {from: mintee});
      
      console.log(result2);
    });
  });
});
