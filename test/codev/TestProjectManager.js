const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManager = artifacts.require("ProjectManagerL");
const IRewardModel = artifacts.require("IRewardModelL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const EvenVoterRewardModel = artifacts.require("EvenVoterRewardModelL");
const WinnerTakesAllModel = artifacts.require("WinnerTakesAllModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("'ProjectManager' contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const rewardModels = [];

  async function prepareFixtures(deployed = false){
    const chance = new Chance();
    const admin = (deployed) ? accounts[0] : chance.pickone(accounts);
    let prjMgr;
    
    if(deployed){
      prjMgr = await ProjectManager.deployed();
    }else{
      const tkn = await RegularERC20Token.new("Environment Social Value Token", "ESV", {from: admin});
      prjMgr = await ProjectManager.new(tkn.address, {from: admin});
    }
    
    return [chance, admin, prjMgr];
  }
  
  async function registerRewardModels(prjMgr, models, admin){
    for(const mdl of models){
      await prjMgr.registerRewardModel(mdl.address, {from: admin});
    }   
  }
  
  before(async() => {
    const accts = [];
    let balance = 0;

    for(const acct of accounts){
        //await web3.eth.personal.unlockAccount(acct);
        await accts.push([acct, await web3.eth.getBalance(acct)]);
    }

    rewardModels.push(await ProportionalRewardModel.deployed());
    rewardModels.push(await EvenVoterRewardModel.deployed());
    rewardModels.push(await WinnerTakesAllModel.deployed());

    //console.debug(`The number of accounts : ${accounts.length}`);
    //console.table(accts);
  });
  
  
  it("Should have no project and a few reward models initially.", async() => {
    const [chance, admin, prjMgr] = await prepareFixtures(true);
    
    const cnt1 = await prjMgr.getNumberOfProjects();
    const cnt2 = await prjMgr.getNumberOfRewardModels();
    
    assert.isTrue(cnt1.isZero(), "Initially there should be no project in a project manager contract.");
    assert.isTrue(cnt2.gtn(0), "Initially there should be no reward model in a project manager contract.");
  });
  
  
  it("Can count the number of created projects", async() => {

    const [chance, admin, prjMgr] = await prepareFixtures(true);
    //await registerRewardModels(prjMgr, rewardModels, admin);
    
    const n = chance.natural({min: 3, max: 10});
    const epc = Date.now();
    let name = null, prjId = 0, totalRwd = 0, cntrbPrct = 0, rwdMdlAddr = 0;
    for(let i = 0; i < n; i++){
      name = chance.word({length: 10});
      totalRwd = toBN(1E20).muln(chance.natural({min: 1, max: 5})); // total reward
      cntrbPrct = chance.natural({min: 1, max: 99});  // contributors reward pecent           
      rwdMdlAddr = chance.pickone(rewardModels).address; // reward model address
      prjId = (epc + i).toString().substring(3);
      
      await prjMgr.createProject(
        prjId, name, totalRwd, cntrbPrct, rwdMdlAddr, {from: admin});
    }
  
    const cnt = await prjMgr.getNumberOfProjects();
    assert.equal(cnt.toNumber(), n, "Number of created projects are different from the number that project manager contract counts");   
    
  });
  
  it("Can register reward models", async() => {
    const [chance, admin, prjMgr] = await prepareFixtures(true);
    const addrs = [], names = [];
    
    for(const model of rewardModels){
      addrs.push(model.address);
      await prjMgr.registerRewardModel(model.address, {from: admin});
      names.push(await model.getName());
    }
    
    const cnt = await prjMgr.getNumberOfRewardModels();
    assert.isTrue(cnt.eqn(rewardModels.length));    
    
    let mdl2 = null;
    const addrs2 = [], names2 = [];
    for(let i = 0; i < cnt; i++){
      mdl2 = await prjMgr.getRewardModel(i);
      addrs2.push(mdl2.addr); // address
      names2.push(mdl2.name); // name
    }
    
    assert.sameMembers(names, names2, "Wrong reward model is registered.");
    assert.sameMembers(addrs, addrs2, "Wrong reward model is registered."); 
    
  });
  
});
  