
const Badge = artifacts.require("ColoredBadge");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');


contract("ColoredBadge contract test suite", async accounts => {
  
  "use strict";
  
  if(accounts.length > 10) acccounts = (new Chance()).pickset(accounts, 10);
  
  async function createFixtures(){
    
    const chance = new Chance();
    const admin = chance.pickone(accounts);
    const badge = await Badge.new(['Red', 'Green']);
    console.debug(`New ColoredBadge contract deployed - address: ${badge.address}`);
    
    return [chance, admin, badge];
  }
  
  before(async () => {
    const output = [];
    for(const acct of accounts){
      await web3.eth.personal.unlockAccount(acct);
      await output.push([acct, await web3.eth.getBalance(acct)]);
    }

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(output);
  });
  
  
  describe("Initial State", () => {
    
    
    it("Should recognize colors specified constructor.", async() => {
      const chance = new Chance();
      const admin = chance.pickone(accounts);
      const badge = await Badge.new(['Deep Purple', 'Hot Pink']);
      
      const colors = await badge.getAllColors();
      
      console.debug(colors);  
      
    });
    
  });
  
});