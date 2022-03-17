const Contract = artifacts.require("ERC721Exportable");


module.exports = async function (deployer, network, accounts) {
  'use strict';
 
  console.debug(`Starting to deploy ${Contract.contractName} contracts`);
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};
  
  await deployer.deploy(Contract, 'My Life Photos', 'MLP', options);
  const cntr = await Contract.deployed();
  
  const logs = [
    {key: 'Target Newtork', value: network},
    {key: 'Deployer Account', value: admin},
    {key: 'Contract Name', value: Contract.contractName},
    {key: 'Deployed Address', value: cntr.address},
    {key: 'Compiler Version', value: Contract.compiler.version},
    {key: 'Deployment time duration (ms)', value: (Date.now() - startAt)}
  ]
  console.table(logs);

}