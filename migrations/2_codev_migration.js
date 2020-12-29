const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const RewardArrayLib = artifacts.require("RewardArrayLib");
const ProjectManager = artifacts.require("ProjectManagerL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const EvenVoterRewardModel = artifacts.require("EvenVoterRewardModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
//const Top2RewardedModel = artifacts.require("Top2RewardedModelL");
const Contributions = artifacts.require("ContributionsL");
const Votes = artifacts.require("VotesL");


module.exports = async function (deployer, network, accounts) {
  'use strict';
  
  
  console.debug('Starting to deploy 8 contracts');
  const startAt = Date.now();
  const admin = accounts[0];
  const options = {from: admin, overwrite: true};

  console.debug("Deploying 'Token' contract.");
  await deployer.deploy(RegularERC20Token, "Environment Social Value Token", "ESV", options);
  await deployer.deploy(RewardArrayLib);
  await deployer.link(RewardArrayLib, ProjectManager);
  
  console.debug("Deploying 'Project Manager' contract and 3 'Reward Model' contracts.")
  await deployer.deploy(ProjectManager, RegularERC20Token.address, options);
  await deployer.deploy(ProportionalRewardModel, 15, 10, options);
  await deployer.deploy(EvenVoterRewardModel, options);
  await deployer.deploy(WinnerTakesAllModel, options);

  console.debug("Granting token minter role to project manager")
  const tkn = await RegularERC20Token.deployed();
  await tkn.grantRole(await tkn.MINTER_ROLE(), ProjectManager.address);
  console.debug("Registering 3 reward models to project manager");
  const mdlAddrs = [
      ProportionalRewardModel.address, 
      EvenVoterRewardModel.address,
      WinnerTakesAllModel.address
  ];
  const prjMgr = await ProjectManager.deployed();
  await prjMgr.registerRewardModels(mdlAddrs, options);
  
  console.debug("Deploying 'Contributions' contract and 'Votes' contract.");
  await deployer.deploy(Contributions, ProjectManager.address, options);
  
  await deployer.deploy(Votes, ProjectManager.address, Contributions.address, options);
  const vts = await Votes.deployed();
  await prjMgr.setVotesContact(Votes.address);
  
//  console.debug("Mining initial balances to 3 voters");
//  const voterIndexes = [6, 7, 8];
//  const voterInitBal = web3.utils.toBN(10E18);
//  for(const i of voterIndexes){
//    await tkn.mint(accounts[i], voterInitBal, options);
//  }
  
  const mdlCnt = await prjMgr.getNumberOfRewardModels();
  console.debug(`Number of registered reward models: ${mdlCnt}`);
  
  const logs = [
    {key: 'Target Network', value: network},
    {key: "Accounts[0]", value: accounts[0]},
    {key: "RegularERC20Token", value: RegularERC20Token.address},
    {key: "ProjectManager", value: ProjectManager.address},
    {key: "ProportionalRewardModel", value: ProportionalRewardModel.address},
    {key: "EvenVoterRewardModel", value: EvenVoterRewardModel.address},
    {key: "WinnerTakesAllModel", value: WinnerTakesAllModel.address},
    {key: "Contributions", value: Contributions.address},
    {key: "Votes", value: Votes.address}]
  
  console.table(logs);
  console.debug(`Finished contract deployment : ${Date.now() - startAt} milli-sec elapsed`);

};

