const ERC721Regular = artifacts.require("ERC721Regular");


module.exports = async function (deployer, network, accounts) {
  'use strict';
 
  console.debug('Starting to deploy ERC721 contracts');
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};
  
  await deployer.deploy(ERC721Regular, 'Deep Sky', 'DSO', options);
  const regularCntr = await ERC721Regular.deployed();
  
  const logs = [
    {key: 'Target Newtork', value: network},
    {key: 'Deployer Account', value: admin},
    {key: 'ERC721Regular Contract', value: regularCntr.address}
  ]
  
  console.table(logs);
  console.debug(`Finished contract deployment: ${Date.now() - startAt} milli-sec.`);

}