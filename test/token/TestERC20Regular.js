
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


    // totalSupply(), paused(), balanceOf()
    it("A token at inital state should have ZERO supply, not be paused, and set ZERO balance for all accounts.", async() => {
      const chance = new Chance();
      const token = await Token.new('Color Token', 'RGB', {from: chance.pickone(accounts)});
      console.debug(`New token deployed into ${token.address}`);

      const total = await token.totalSupply();
      const paused = await token.paused();

      assert.isTrue(total.isZero());
      assert.isFalse(paused);

      let balance = 0;
      for(const acct of accounts){
        balance = await token.balanceOf(acct);
        assert.isTrue(balance.isZero());
      }
    });
  });

  describe("Minting", () => {

    // mint(), totalSupply(), balanceOf()
    it("Minting tokens should increase the owners balance and total supply", async() => {
      const chance = new Chance();
      const admin = chance.pickone(accounts);
      const token = await Token.new('Color Token', 'RGB', {from: admin});
      console.debug(`New token deployed into ${token.address}`);

      const amt0 = toBN(1E17);
      let amt = null;
      let balance1 = 0, balance2 = 0;
      let total1 = 0, total2 = 0;
      for(const acct of accounts){
        balance1 = await token.balanceOf(acct);
        total1 = await token.totalSupply();

        // mint
        amt = amt0.muln(chance.natural({min: 1, max: 100}));
        await token.mint(acct, amt, {from: admin});

        balance2 = await token.balanceOf(acct);
        total2 = await token.totalSupply();

        assert.isTrue(balance2.eq(balance1.add(amt)), "Minting should increase balance of the minted account as much.");
        assert.isTrue(total2.eq(total1.add(amt)), "Minting should increase total supply as much.");
      }
    });

    it("Only minter can 'mint' a token.", async() =>{
      const chance = new Chance();
      const admin = chance.pickone(accounts);
      const token = await Token.new('Color Token', 'RGB', {from: admin});
      console.debug(`New token deployed into ${token.address}`);

      let tryer = null;
      do{ // select any account other than admin
        tryer = chance.pickone(accounts);
      }while(tryer == admin)

      let amt = 0;
      for(const acct of accounts){
        amt = toBN(1E17).muln(chance.natural({min: 1, max: 100}));

        // tryer is not minter or admin yet
        expectRevert.unspecified(token.mint(acct, amt, {from: tryer}));
      }

      // maker tryer minter
      await token.grantRole(await token.MINTER_ROLE(), tryer, {from: admin});

      // try again as a minter
      for(const acct of accounts){
        amt = toBN(1E17).muln(chance.natural({min: 1, max: 100}));

        await token.mint(acct, amt, {from: tryer});
      }

    });

    it("Minting should fire 'Transfer' event.", async() => {
      const chance = new Chance();
      const admin = chance.pickone(accounts);
      const token = await Token.new('Color Token', 'RGB', {from: admin});
      console.debug(`New token deployed into ${token.address}`);

      let amt = 0;
      for(const acct of accounts){
        amt = toBN(1E17).muln(chance.natural({min: 1, max: 100}));

        expectEvent(await token.mint(acct, amt, {from: admin}),
          EventNames.Transfer, {1: acct, 2: amt});
      }
    })
  });

  describe("Transfer", () => {




  });


  describe("Approval", () => {


  });


  describe("Delegated Transfer", () => {


  });


  describe("Burning", () => {


  });

  describe("Circuit Breaker", () => {


  });

});