const Token = artifacts.require("ERC721Exportable");
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
const CONTRACT_ADDRESS = '0xB31504D8969f21cD787037288135b6FFe0BD81De';

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

  describe("Export and import", () => {
    
    let [chance, admin, token] = [null, null, null];
    
    before(async () => {
      [chance, admin, token] = await createFixtures();
    });

    it("Owner can set a token in normal status (owned by someone) to be exporting losing the ownership.", async() => {
      
      const mintee = accounts[1];
      const result = await token.mint(mintee, {from: admin});
      
      assert.isTrue(result.receipt.status);
      assert.equal(result.logs[0].event, EventNames.Transfer);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      // try to burn the right previously minted token
      const result2 = await token.exporting(id, {from: mintee});
      
      assert.isTrue(result2.receipt.status);
      assert.isAbove(result.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      
      console.log(`Token ${id} is set to be exporting.`);
    });
    
    it("Admin can set a token in exporting status to be exported.", async() =>{
      
      const mintee = accounts[1];
      const result = await token.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      // try to burn the right previously minted token
      const result2 = await token.exporting(id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      console.log(`Token ${id} is set to be exporting.`);

      const result3 = await token.exported(id, {from: admin});
      assert.isTrue(result3.receipt.status);
      
      console.log(`Token ${id} is set to be exported.`);
    });
    
    
    it("Admin can set a token in exported status to be imported.", async() =>{
      
      const mintee = accounts[1];
      const result = await token.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      // try to burn the right previously minted token
      const result2 = await token.exporting(id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      console.log(`Token ${id} is set to be exporting.`);

      const result3 = await token.exported(id, {from: admin});
      assert.isTrue(result3.receipt.status);
      
      console.log(`Token ${id} is set to be exported.`);
      
      const result4 = await token.imported(id, mintee);
      assert.isTrue(result4.receipt.status);
      assert.isAbove(result4.logs.filter(log => log.event == EventNames.Transfer).length, 0);

      console.log(result4);
    });
    
    
  });
});
