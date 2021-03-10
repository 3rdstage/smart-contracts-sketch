const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')

contract("Test nonce increments for an address in a single/standalone node.", async accounts => {
  
  
  'use strict';
 
  
  it("Would increase nonce for every transaction request.", async() => {
    
    const amt = 1000; // 1,000 wei
    
    const test = async(acct1, acct2) => {
      const nc10 = await web3.eth.getTransactionCount(acct1); // nonce for sender before tx.
      await web3.eth.sendTransaction({from: acct1, to: acct2, value: amt});
      const nc11 = await web3.eth.getTransactionCount(acct1); // nonce for sender after tx.    
    
      console.log(`nonces for sender before/after tx : ${nc10}/${nc11}, gap : ${nc11 - nc10}`);
    }
    
    for(let i = 0; i < 10; i++) await test(accounts[0], accounts[1]);
   
    
  })  
  
  
})