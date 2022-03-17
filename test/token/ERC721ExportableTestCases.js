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

const States = {
  Exporting: 'Exporting',
  Exported: 'Exported',
  Imported: 'Imported'
}

async function assertTokenInStateOnly(contract, id, state){
  const tokens = new Map();
  tokens.set(States.Exporting, await contract.exportingTokens());
  tokens.set(States.Exported, await contract.exportedTokens());
  tokens.set(States.Imported, await contract.importedTokens());

  for(let key of tokens.keys()){
    if(key == state) assert.deepInclude(tokens.get(key), id);
    else assert.notDeepInclude(tokens.get(key), id)
  }
  
  console.debug(`Exporting tokens : ${tokens.get(States.Exporting)}`);
  console.debug(`Exported tokens : ${tokens.get(States.Exported)}`);
  console.debug(`Imported tokens : ${tokens.get(States.Imported)}`);
}

exports.exportTest = (accounts, admin, factoryFunc) => {
  
  describe("Normal cases", () => {
    
    let contract = null;
    
    before(async() => {
      contract = await factoryFunc(admin);
    });

    it("A token in normal state(owned by someone) can set exporting by the approved.", async() => {
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const result = await contract.mint(mintee, {from: admin});
      
      assert.isTrue(result.receipt.status);
      assert.equal(result.logs[0].event, EventNames.Transfer);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);
      
      const result2 = await contract.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      const result3 = await contract.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      assert.isAbove(result3.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      console.log(`Token ${id} is set exporting.`);
      
      await assertTokenInStateOnly(contract, id, States.Exporting);
    });
    
    it("A token in exporting state can be set exported by the current owner.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const result = await contract.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);

      const result2 = await contract.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      const result3 = await contract.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      console.log(`Token ${id} is set exporting.`);

      const result4 = await contract.exported(id, {from: escrowee});
      assert.isTrue(result4.receipt.status);
      console.log(`Token ${id} is set exported.`);
      
      await assertTokenInStateOnly(contract, id, States.Exported);
      
    });
    
    it("A token in exported state can be set imported to a new owner by the minter.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3];
      const result = await contract.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);

      const result2 = await contract.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      const result3 = await contract.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      console.log(`Token ${id} is set exporting.`);

      const result4 = await contract.exported(id, {from: escrowee});
      assert.isTrue(result4.receipt.status);
      console.log(`Token ${id} is set exported.`);
      
      const result5 = await contract.imported(id, importee, {from: admin});
      assert.isTrue(result5.receipt.status);
      assert.isAbove(result5.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      console.log(`Token ${id} is imported.`);

      await assertTokenInStateOnly(contract, id, States.Imported);
    });
    
    it("A token previously imported can be set exporting by the approved.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3];
      const result = await contract.mint(mintee, {from: admin});
      assert.isTrue(result.receipt.status);
      
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.log(`A new token of ID ${id} is minted.`);

      const result2 = await contract.approve(escrowee, id, {from: mintee});
      assert.isTrue(result2.receipt.status);
      
      const result3 = await contract.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result3.receipt.status);
      console.log(`Token ${id} is set exporting.`);

      assert.isTrue(toBN(await contract.getApproved(id)).eqn(0))
      
      const result4 = await contract.exported(id, {from: escrowee});
      assert.isTrue(result4.receipt.status);
      console.log(`Token ${id} is set exported.`);
      
      const result5 = await contract.imported(id, importee, {from: admin});
      assert.isTrue(result5.receipt.status);
      assert.isAbove(result5.logs.filter(log => log.event == EventNames.Transfer).length, 0);
      console.log(`Token ${id} is imported.`);

      const result6 = await contract.approve(escrowee, id, {from: importee});
      assert.isTrue(result6.receipt.status);
      
      const result7 = await contract.exporting(id, escrowee, {from: escrowee});
      assert.isTrue(result7.receipt.status);
      console.log(`Token ${id} is set exporting.`);
      
      assert.isTrue(toBN(await contract.getApproved(id)).eqn(0))

      await assertTokenInStateOnly(contract, id, States.Exporting);

    });
    
    
  });
};

