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

/**
 * Mint a new token and return the ID.
 *
 * @returns the ID of minted token
 */
async function mint(contract, admin, mintee){
  const result = await contract.mint(mintee, {from: admin});
  const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
  console.debug(`A new token of ID ${id} is minted. - owner: ${mintee}, minter: ${admin}`);
  
  return id;
}

/**
 * Mint a new token and set it exporting.
 *
 * @returns the ID of token exporting
 */
async function mintToExporting(contract, admin, mintee, escrowee){
  const id = await mint(contract, admin, mintee);
  await contract.approve(escrowee, id, {from: mintee});
  await contract.exporting(id, escrowee, {from: escrowee});
  console.debug(`The token ${id} is exporting. - escrowee: ${escrowee}`);
  
  return id;
}

/**
 * Mint a new token, set it exporting and then set it exported.
 *
 * @returns the ID of exported token
 */
async function mintToExported(contract, admin, mintee, escrowee){

  const id = await mintToExporting(contract, admin, mintee, escrowee);
  await contract.exported(id, {from: escrowee});
  console.debug(`The token ${id} is exported.`);
  
  return id;
}

/**
 * Mint a new token, set it exporting, exported and then import it.
 *
 * @returns the ID of token imported
 */
async function mintToImported(contract, admin, mintee, escrowee, importee){
  const id = await mintToExported(contract, admin, mintee, escrowee);
  await contract.imported(id, importee, {from: admin});
  console.debug(`The token ${id} is imported. - importee: ${importee}, minter: ${admin}`);
  
  return id;
}

// TODO - Check the number of accounts is equal or more than the minimun 7 or more

exports.basicCases = (accounts, admin, factoryFunc) => {
  
  describe("Normal basic cases", () => {
    
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


exports.extendedCases = (accounts, admin, factoryFunc) => {
  
  describe("Normal extended cases", () => {
    
    let contract = null;
    
    before(async() => {
      contract = await factoryFunc(admin);
    });
    
    
    it("A token imported can be transferred by the owner.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3]; // owner of imported token
      const recipient = chance.pickone(accounts.filter(acct => acct != importee));
      
      const id = await mintToImported(contract, admin, mintee, escrowee, importee);
      const result = await contract.transferFrom(importee, recipient, id, {from: importee});
      assert.isTrue(result.receipt.status);
      
      console.debug(`The token ${id} is transferred - from: ${importee}, to: ${recipient}, by: ${importee}`);
    });
    
    it("A token imported can be transferred by the approved.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3]; // owner of imported token
      const [approved, recipient] = chance.pickset(accounts.filter(acct => acct != importee), 2);
      
      const id = await mintToImported(contract, admin, mintee, escrowee, importee);
      await contract.approve(approved, id, {from: importee});
      console.debug(`The token ${id} is approved. - owner: ${importee}, approved: ${approved}`)

      const result = await contract.transferFrom(importee, recipient, id, {from: approved});
      assert.isTrue(result.receipt.status);
      console.debug(`The token ${id} is transferred. - from: ${importee}, to: ${recipient}, by: ${approved}`);
    });
    
    it("Setting a token exporting doesn't change total supply at all.", async() => {
      const chance = new Chance();
      const loops = chance.natural({min: 3, max: 7});
      
      let mintee = null, escrowee = null;
      let id =0, tokens = 0, tokens2 = 0;
      for(let i = 0; i < loops; i++){
        [mintee, escrowee] = chance.pickset(accounts, 2);
        id = await mint(contract, admin, mintee);
        tokens = await contract.totalSupply(); // total supply before exporting
        console.debug(`Total supply is ${tokens}`);

        await contract.exporting(id, escrowee, {from: mintee});
        tokens2 = await contract.totalSupply();
        assert.isTrue(tokens.eq(tokens2));
        console.debug(`Total supply remains unchanged after exporting. - ${tokens2}`);
      };
    });
    
    it("Setting a token exported decreases total supply by 1.", async() => {
      const chance = new Chance();
      const loops = chance.natural({min: 3, max: 7});
      
      let mintee = null, escrowee = null;
      let id =0, tokens = 0, tokens2 = 0;
      for(let i = 0; i < loops; i++){
        [mintee, escrowee] = chance.pickset(accounts, 2);
        id = await mintToExporting(contract, admin, mintee, escrowee);
        tokens = await contract.totalSupply(); // total supply before exporting
        console.debug(`Total supply is ${tokens}`);

        await contract.exported(id, {from: escrowee});
        tokens2 = await contract.totalSupply();
        assert.isTrue(tokens.subn(1).eq(tokens2));
        console.debug(`Total supply decreases by 1 after exported token ${id}. - ${tokens2}`);
      };
    });
    
    it("Setting a token imported increases total supply by 1.", async() => {
      const chance = new Chance();
      const loops = chance.natural({min: 3, max: 7});
      
      let mintee = null, escrowee = null;
      let id =0, tokens = 0, tokens2 = 0;
      for(let i = 0; i < loops; i++){
        [mintee, escrowee, importee] = chance.pickset(accounts, 3);
        id = await mintToExported(contract, admin, mintee, escrowee);
        tokens = await contract.totalSupply(); // total supply before exporting
        console.debug(`Total supply is ${tokens}`);

        await contract.imported(id, importee, {from: admin});
        tokens2 = await contract.totalSupply();
        assert.isTrue(tokens.addn(1).eq(tokens2));
        console.debug(`Total supply increases by 1 after imported token ${id}. - ${tokens2}`);
      };
    });
    
    
  });
};

exports.abnormalCases = (accounts, admin, factoryFunc) => {
    
  describe("Abnormal cases", () => {
    
    let contract = null;
    
    before(async() => {
      contract = await factoryFunc(admin);
    });
    
    it("A token ID not minted yet can't be set exporting.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const importee = accounts[3];
      
      const n = await contract.totalSupply();
      
      await expectRevert.unspecified(contract.exporting(n.addn(100), escrowee, {from: admin}));
    });
    
    it("A token in exporting state can't be set exporting.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      
      const id = await mintToExporting(contract, admin, mintee, escrowee)
      
      const accounts2 = chance.pickset(accounts.filter(acct => acct != escrowee), 5);
      for(const acct of accounts2){
        await contract.approve(acct, id, {from: escrowee});
        await expectRevert.unspecified(contract.exporting(id, acct, {from: escrowee}));
      }
    });
    
    
    it("A token in exported state can't be approved to anyone.", async() => {
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      const anyone = chance.pickone(accounts);
      
      const id = await mintToExported(contract, admin, mintee, escrowee);
      
      await expectRevert.unspecified(contract.approve(anyone, id, {from: admin}));
      await expectRevert.unspecified(contract.approve(anyone, id, {from: mintee}));
      await expectRevert.unspecified(contract.approve(anyone, id, {from: escrowee}));
      await expectRevert.unspecified(contract.approve(anyone, id, {from: anyone}));
    });
    
    
    it("A token in exported state can't be set exporting.", async() => {
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      
      const id = await mintToExported(contract, admin, mintee, escrowee);
      
      await expectRevert.unspecified(contract.exporting(id, chance.pickone(accounts), {from: admin}));
      
      const accounts2 = chance.pickset(accounts, 5);
      for(const acct of accounts2){
        await expectRevert.unspecified(contract.exporting(id, acct, {from: acct}));
      }
    });
    
    it("A token in normal state can't be set exported by the message sender who is not the onwer nor the approved.", async() => {
      const chance = new Chance();
      const mintee = accounts[1];
      const escrowee = accounts[2];
      
      const result = await contract.mint(mintee, {from: admin});
      const id = result.logs.filter(log => log.event == EventNames.Transfer)[0].args.tokenId;
      console.debug(`A new token of ID ${id} is minted.`);

      const accounts2 = chance.pickset(accounts.filter(acct => ![mintee, escrowee].includes(acct)), 5);
      for(const acct of accounts2){
        await expectRevert.unspecified(contract.exporting(id, acct, {from: acct}));
      }
    });
  });
};


exports.unusualCases = (accounts, admin, factoryFunc) => {
    
  describe("Abnormal cases", () => {
    
    let contract = null;
    
    before(async() => {
      contract = await factoryFunc(admin);
    });

    it("A token can be set exporting escrowed by the current owner.", async() =>{
      const chance = new Chance();
      const mintee = accounts[1];
      
      const id = await mint(contract, admin, mintee);
      const result = await contract.exporting(id, mintee, {from: mintee});
      assert.isTrue(result.receipt.status);
      const escrowee = await contract.ownerOf(id);
      
      console.debug(`Exporting token ${id} is escrowed to ${escrowee}`);
      
    });
  });
};