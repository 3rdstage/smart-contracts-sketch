const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const Web3TestContract = artifacts.require("Web3TestContract");

contract("'Web3Testcontract' contract uint tests", async accounts => {
  
  'use strict';

  async function prepareFixtures(){
    const chance = new Chance();
    const admin = accounts[0];

    return [chance, admin];
  }

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);
  it("Count up", async() => {

    const [chance, admin] = await prepareFixtures(true);
    const testContr = await Web3TestContract.deployed();

    await testContr.countUp();

  });
});