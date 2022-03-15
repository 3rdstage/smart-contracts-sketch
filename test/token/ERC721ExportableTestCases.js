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

"use strict";
const EventNames = {
  Transfer: 'Transfer',
  Approval: 'Approval'
}

exports.exportTest = (accounts, admin, factoryFunc) => {
  
  describe("Export and import", () => {
    
    let token = null;
    
    before(async() => {
      token = await factoryFunc(admin);
    });

    it("A token in normal state(owned by someone) can set to be exporting by the approved.", async() => {
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const result = await token.mint(mintee, {from: admin});
      
      assert.isTrue(result.receipt.status);
      assert.equal(result.logs[0].event, EventNames.Transfer);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      const result2 = await token.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      // try to burn the right previously minted token
      const result3 = await token.exporting(id, escrowee, {from: escrowee});
      
      assert.isTrue(result3.receipt.status);
      assert.isAbove(result3.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      
      console.log(`Token ${id} is set to be exporting.`);
      
      const exportings = await token.exportingTokens();
      
      assert.deepInclude(exportings, id);
      console.log(exportings);
      
    });
    
    it("A token in exporting state can be set to be exported by the current owner.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const result = await token.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);

      const result2 = await token.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      // try to burn the right previously minted token
      const result3 = await token.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      
      console.log(`Token ${id} is set to be exporting.`);

      const result4 = await token.exported(id, {from: escrowee});
      assert.isTrue(result4.receipt.status);
      
      console.log(`Token ${id} is set to be exported.`);
      
      const exportings = await token.exportingTokens();
      assert.notDeepInclude(exportings, id);
      console.log(`Exporting tokens : ${exportings}`)
      
      const exporteds = await token.exportedTokens();
      assert.deepInclude(exporteds, id);
      console.log(`Exported tokens : ${exporteds}`);
      
    });
    
    
    it("A token in exported state can be imported to a new owner by the minter", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3];
      const result = await token.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);

      const result2 = await token.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      // try to burn the right previously minted token
      const result3 = await token.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      
      console.log(`Token ${id} is set to be exporting.`);

      const result4 = await token.exported(id, {from: escrowee});
      assert.isTrue(result4.receipt.status);
      
      console.log(`Token ${id} is set to be exported.`);
      
      const result5 = await token.imported(id, importee, {from: admin});
      assert.isTrue(result5.receipt.status);
      assert.isAbove(result5.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      
      console.log(`Token ${id} is imported.`);

      const exportings = await token.exportingTokens();
      assert.notDeepInclude(exportings, id);
      console.log(`Exporting tokens : ${exportings}`)
      
      const exporteds = await token.exportedTokens();
      assert.notDeepInclude(exporteds, id);
      console.log(`Exported tokens : ${exporteds}`);
      
      const importeds = await token.importedTokens();
      assert.deepInclude(importeds, id);
      console.log(`Imported tokens : ${importeds}`);
    });
    
  });
};

