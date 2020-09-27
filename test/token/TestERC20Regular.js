
const Token = artifacts.require("ERC20Regular");
const Chance = require('chance');
const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const toBN = web3.utils.toBN;

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

contract("ERC20Practical Contract Test Suite", async accounts => {
  

  // avoid too many accounts
  if(accounts.length > 8) accounts = accounts.slice(0, 8);
  
  const creator1 = accounts[0];  // default token creator in test - admin, minter, pauser
  const creator2 = accounts[1];
  
  const EventNames = {
      Transfer: 'Transfer',
      Approval: 'Approval'  
  }
    
  before(async() => {
    const output = [];
    let balance = 0;
    
    for(const acct of accounts){
      await web3.eth.personal.unlockAccount(acct);
      balance = await web3.eth.getBalance(acct);
      await output.push([acct, balance]);
    }
    
    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(output);
    
  });
  
  describe("Initial State", () => {
    
    // name(), symbol(), decimals()
    it("A token should have 'name' and 'symbol' specified at the constructor and always have '18' for the decimals.", async() => {
      const chance = new Chance();
      const name = chance.sentence({words: 3});
      const symbol = chance.word({length: chance.natural({min: 1, max: 5})}).toUpperCase();
      const admin = chance.pickone(accounts);
      const token = await Token.new(name, symbol, {from: admin});
      console.debug(`New token deployed into ${token.address}`);
      console.debug(`   Name: '${name}', Symbol: '${symbol}'`);
      
      // inquire and verify token's name, symbol and decimals
      assert.equal(await token.name(), name);
      assert.equal(await token.symbol(), symbol);
      assert.isTrue((await token.decimals()).eq(toBN(18)));
    });
    
    
    it("A token at inital state should have ZERO supply, not be paused, and set ZERO balance for all accounts.", async() => {
      const chance = new Chance();
      const token = await Token.new('Color Token', 'RGB', {from: chance.pickone(accounts)});
      console.debug(`New token deployed into ${token.address}`);
      
      const total = await token.totalSupply();
      const paused = await token.paused();
      
      assert.isTrue(total.isZero());
      assert.isFalse(paused);
      
      let balance = 0;
      for(acct of accounts){
        balance = await token.balanceOf(acct);
        assert.isTrue(balance.isZero());
      }
    });  
  });

  
  
});