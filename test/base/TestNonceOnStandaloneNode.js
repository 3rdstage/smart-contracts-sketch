const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers')

contract("Test nonce increments for an address in a single/standalone node.", async accounts => {
  
  'use strict';
  
  //TOO Try another test case in which signing is done at client.
  
  before(async() => {
    if(accounts.length < 2){
      assert.fail("At least 2 accounts should be available.");
    }
    
    let bal = await web3.eth.getBalance(accounts[0]);
    if(bal < 1000000){
      assert.fail("First account should have enough balance, maybe more than 1,000,000 wei");
    }
    //TODO check if the current block time is long enough, may be more than 3 seconds
  });
  
  it("Would increase nonce for every transaction request.", async() => {
    
    const amt = 1000; // 1,000 wei
    const n = 3;      // transaction count to send
    
    const test = async(acct1, acct2) => {
      const nc10 = await web3.eth.getTransactionCount(acct1); // nonce for sender before tx.
      await web3.eth.sendTransaction({from: acct1, to: acct2, value: amt});
      const nc11 = await web3.eth.getTransactionCount(acct1); // nonce for sender after tx.    
    
      console.log(`nonces for sender before/after tx : ${nc10}/${nc11}, gap : ${nc11 - nc10}`);
    }
    
    const acct1 = accounts[0];
    const acct2 = accounts[1];

    let nc = await web3.eth.getTransactionCount(acct1);
    console.log(`Sender's nonce before transactions : ${nc}`);

    const hashes = [];
    for (let i  = 0; i < n; i++){
      web3.eth.sendTransaction({from: acct1, to: acct2, value: amt})
      .on('transactionHash', function(hash){
          hashes.push(hash);
        });
      console.log(`Transaction sent : `);  
    }
    
    nc = await web3.eth.getTransactionCount(acct1);
    console.log(`Sender's nonce right after ${n} transactions but before being mined : ${nc}`)

    while(hashes.length < n) await new Promise(r => setTimeout(r, 1000))
    let tx = null;
    let blkNo = null;
    for (let i = 0; i < n; i++){
      while(true){
        tx = await web3.eth.getTransaction(hashes[i]);
        if(tx.blockNumber == null) await new Promise(r => setTimeout(r, 1000))
        else break;
      }
      console.log(`Transaction : ${JSON.stringify(tx)}`);
    }
    
    nc = await web3.eth.getTransactionCount(acct1);
    console.log(`Sender's nonce right after ${n} transactions are mined : ${nc}`);
  })  
  
})