const TokenContract = artifacts.require("ERC721Exportable");
const testcases = require('./ERC721ExportableTestCases');


const factoryFunc = async (admin) => {
  const token = await TokenContract.new('Awesome Photos', 'APH', {from: admin});
  
  console.debug(`New contract deployed - name: ${TokenContract.toJSON().contractName}, address: ${token.address}`)
  return token;
}

"use strict";
contract("ERC721Exportable Contract Test Suite", async accounts => {

  // avoid too many accounts
  //if(accounts.length > 8) accounts = (new Chance()).pickset(accounts, 8);

  before(async () => {
    const output = [];
    for(const acct of accounts){
      //await web3.eth.personal.unlockAccount(acct); // not working with Rinkeby
      await output.push([acct, await web3.eth.getBalance(acct)]);
    }

    console.debug(`The number of accounts : ${accounts.length}`);
    console.table(output);
  });
  
  
  testcases.exportTest(accounts, accounts[0], factoryFunc);
    
});

