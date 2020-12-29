const RegularERC20Token = artifacts.require("RegularERC20TokenL");
const ProjectManagerContr = artifacts.require("ProjectManagerL");
const ProportionalRewardModelContract = artifacts.require("ProportionalRewardModelL");
const ContributionsContr = artifacts.require("ContributionsL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("'Contribution' contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function

  async function prepareFixtures(deployed = false){
    
    const chance = new Chance();
    const admin = (deployed) ? accounts[0] : chance.pickone(accounts);
    let tknContr, prjMgrContr, contribsContr;
    
    if(deployed){
      prjMgrContr = await ProjectManagerContr.deployed();
      contribsContr = await ContributionsContr.deployed();
    }else{
      tknContr = await RegularERC20Token.new("Environment Social Value Token", "ESV", {from: admin});
      prjMgrContr = await ProjectManagerContr.new(tknContr.address, {from: admin});
      const rwdModelContr = await ProportionalRewardModelContract.new(15, 10, {from: admin})
      await prjMgrContr.registerRewardModel(rwdModelContr.address, {from: admin});
      contribsContr = await ContributionsContr.new(prjMgrContr.address, {from: admin});
    }
  
    return [chance, admin, prjMgrContr, contribsContr];
  }
  
  before(async() => {
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");
    
    votees.push(accounts[3], accounts[4], accounts[5]);
    voters.push(accounts[6], accounts[7], accounts[8]);

    const accts = [];
    let balance = 0;
    for(const acct of accounts){
        await accts.push([acct, await web3.eth.getBalance(acct)]);
    }

    //console.debug(`The number of accounts : ${accounts.length}`);
    //console.table(accts);
  });
  
  it("Can register contributions", async() => {

    const [chance, admin, prjMgrContr, contribsContr] = await prepareFixtures(true);
    const rwdMdl = await prjMgrContr.getRewardModel(0);    
    
    const prj = { id: Date.now().toString().substring(3),
                  name: 'p1', totalReward: toBN(1E20), totalRewardStr: '1E20',
                  contribPrct: 70, rewardModelAddr: rwdMdl.addr};
    
    const rcpt = await prjMgrContr.createProject(prj.id, prj.name, prj.totalReward, 
        prj.contribPrct, prj.rewardModelAddr, {from: admin});
    expectEvent(rcpt, 'ProjectCreated');
    const ev = rcpt.logs[0].args;
  });

});