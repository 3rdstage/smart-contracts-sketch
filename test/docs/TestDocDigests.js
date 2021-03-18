
const DocDigests = artifacts.require("DocDigests");
const Chance = require('chance');
const [toBN, fromWei] = [web3.utils.toBN, web3.utils.fromWei];
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("Test DocDigests contract.", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);
  
  async function prepareFixtures(){
    const chance = new Chance();
    
    const docDigests = await DocDigests.deployed();
    
    return [chance, docDigests];
    
  }

  it("", async() => {
    const [chance, docDigests] = await prepareFixtures();
    
    await docDigests.addDoc(
      "Preformance Test Script.", "jmx", "pref-test.jmx", "", "abc", "SHA256", [], {from: accounts[0]});
  })
    
})