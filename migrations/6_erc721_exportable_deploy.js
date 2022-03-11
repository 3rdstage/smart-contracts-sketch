const ERC721Exportable = artifacts.require("ERC721Exportable");


module.exports = async function (deployer, network, accounts) {
  'use strict';
 
  console.debug('Starting to deploy ERC721 contracts');
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};
  
  await deployer.deploy(ERC721Exportable, 'Deep Sky 2', 'DSO', options);
  const cntr = await ERC721Exportable.deployed();
  
  const logs = [
    {key: 'Target Newtork', value: network},
    {key: 'Deployer Account', value: admin},
    {key: 'ERC721Exportable Contract', value: cntr.address},
    {key: 'Compiler Version', value: ERC721Exportable.compiler.version}
  ]
  
  console.table(logs);
  console.debug(`Finished contract deployment: ${Date.now() - startAt} milli-sec.`);

}