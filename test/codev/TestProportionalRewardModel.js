const IRewardModel = artifacts.require("IRewardModelL");
const ProportionalRewardModel = artifacts.require("ProportionalRewardModelL");
const Chance = require('chance');
const toBN = web3.utils.toBN;
const { constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

contract("'ProportionalRewardModel' contract uint tests", async accounts => {
  
  'use strict';

  // avoid too many accounts
  if(accounts.length > 10) accounts = accounts.slice(0, 10);

  const votees = []; // fill in the `before` function
  const voters = []; // fill in the `before` function
  const floorAt = 16;

  async function prepareFixtures(deployed = true){
 
    const chance = new Chance();
    const admin = (deployed) ? accounts[0] : chance.pickone(accounts);
    const rwdModel = (deployed) ?
        await ProportionalRewardModel.deployed() : await ProportionalRewardModel.new(15, 10, {from: admin});

    return [chance, admin, rwdModel];
  }
  
  
  before(async() => {
    assert.isAtLeast(accounts.length, 8, "There should at least 8 accounts to run this test.");

    votees.push(accounts[3], accounts[4], accounts[5]);
    voters.push(accounts[6], accounts[7], accounts[8]);

    const accts = [];
    let balance = 0;
    for(const acct of accounts){
        //await web3.eth.personal.unlockAccount(acct);
        await accts.push([acct, await web3.eth.getBalance(acct)]);
    }

    //console.debug(`Votees : ${votees.length}`);
    //console.table(votees);
    //console.debug(`Voters : ${voters.length}`);
    //console.table(voters);
    
  });
  
  it("Can calculate the contest scenario", async() => {
    
    const [chance, admin, rwdModel] = await prepareFixtures(true);
    const rwdPot = {total: toBN(1E20).toString(), contribsPercent: 70};

    const vts = [];           // votes
    vts.push({voter: voters[0], votee: votees[0], amount: toBN(3E18).toString()});  // voter1 -> A, 3ESV 
    vts.push({voter: voters[1], votee: votees[0], amount: toBN(3E18).toString()});  // voter2 -> A, 3ESV
    vts.push({voter: voters[2], votee: votees[1], amount: toBN(4E18).toString()});  // voter3 -> B, 4ESV
        
    const scrs = [];          // scores
    scrs.push({owner: votees[0], value: toBN(6E18).toString()});
    scrs.push({owner: votees[1], value: toBN(4E18).toString()});
    
    const rslt = await rwdModel.calcRewards(rwdPot, vts, scrs, floorAt);
    
    assert.equal(scrs.length, rslt.voteeRewards.length);
    assert.equal(vts.length, rslt.voterRewards.length);
    assert.isTrue(rslt.remainder.gtn(0));
    assert.isTrue(toBN(42E18).eq(toBN(rslt.voteeRewards[0].amount)));
    assert.isTrue(toBN(28E18).eq(toBN(rslt.voteeRewards[1].amount)));
    
    const rngs = [
      [toBN(10.38E18), toBN(10.39E18)],
      [toBN(10.38E18), toBN(10.39E18)],
      [toBN(9.23E18), toBN(9.24E18)] ]
    let amt = 0;
    for(let i = 0; i < rslt.voterRewards.length; i++){
      amt = toBN(rslt.voterRewards[i].amount);
      assert.isTrue(amt.gte(rngs[i][0]) && amt.lte(rngs[i][1]));
    }
    
    let sm = toBN(rslt.remainder);
    for(const rwd of rslt.voteeRewards) sm = sm.add(toBN(rwd.amount));
    for(const rwd of rslt.voterRewards) sm = sm.add(toBN(rwd.amount));
    assert.isTrue(toBN(rwdPot.total).eq(sm));
    console.log(sm.toString());
  });

  it("Can calculate a scenario where 2 votees have same score.", async() => {
    
    const [chance, admin, rwdModel] = await prepareFixtures(true);
    const rwdPot = {total: toBN(1E20).toString(), contribsPercent: 70};

    const vts = [];           // votes
    vts.push({voter: voters[0], votee: votees[0], amount: toBN(3E18).toString()});  // voter1 -> A, 3ESV 
    vts.push({voter: voters[1], votee: votees[0], amount: toBN(3E18).toString()});  // voter2 -> A, 3ESV
    vts.push({voter: voters[2], votee: votees[1], amount: toBN(6E18).toString()});  // voter3 -> B, 4ESV
        
    const scrs = [];          // scores
    scrs.push({owner: votees[0], value: toBN(6E18).toString()});
    scrs.push({owner: votees[1], value: toBN(6E18).toString()});
    
    const rslt = await rwdModel.calcRewards(rwdPot, vts, scrs, floorAt);
    
    assert.equal(scrs.length, rslt.voteeRewards.length);
    assert.equal(vts.length, rslt.voterRewards.length);
    assert.isTrue(rslt.remainder.gten(0));
    assert.isTrue(toBN(35E18).eq(toBN(rslt.voteeRewards[0].amount)));
    assert.isTrue(toBN(35E18).eq(toBN(rslt.voteeRewards[1].amount)));
    
    assert.isTrue(toBN(7.5E18).eq(toBN(rslt.voterRewards[0].amount)));
    assert.isTrue(toBN(7.5E18).eq(toBN(rslt.voterRewards[1].amount)));
    assert.isTrue(toBN(15E18).eq(toBN(rslt.voterRewards[2].amount)));
    
    let sm = toBN(rslt.remainder);
    for(const rwd of rslt.voteeRewards) sm = sm.add(toBN(rwd.amount));
    for(const rwd of rslt.voterRewards) sm = sm.add(toBN(rwd.amount));
    assert.isTrue(toBN(rwdPot.total).eq(sm));
    console.log(sm.toString());
  });


  it("Can calculate a scenario where only one votee among 2 votees won all votes", async() => {
    
    const [chance, admin, rwdModel] = await prepareFixtures(true);
    const rwdPot = {total: toBN(1E20).toString(), contribsPercent: 70};

    const vts = [];           // votes
    vts.push({voter: voters[0], votee: votees[0], amount: toBN(3E18).toString()});  // voter1 -> A, 3ESV 
    vts.push({voter: voters[1], votee: votees[0], amount: toBN(3E18).toString()});  // voter2 -> A, 3ESV
    vts.push({voter: voters[2], votee: votees[0], amount: toBN(4E18).toString()});  // voter3 -> B, 4ESV
        
    const scrs = [];          // scores
    scrs.push({owner: votees[0], value: toBN(10E18).toString()});
    scrs.push({owner: votees[1], value: toBN(0).toString()});
    
    const rslt = await rwdModel.calcRewards(rwdPot, vts, scrs, floorAt);
    
    assert.equal(scrs.length, rslt.voteeRewards.length);
    assert.equal(vts.length, rslt.voterRewards.length);
    assert.isTrue(rslt.remainder.gten(0));
    assert.isTrue(toBN(70E18).eq(toBN(rslt.voteeRewards[0].amount)));
    assert.isTrue(toBN(0).eq(toBN(rslt.voteeRewards[1].amount)));
    
    assert.isTrue(toBN(9E18).eq(toBN(rslt.voterRewards[0].amount)));
    assert.isTrue(toBN(9E18).eq(toBN(rslt.voterRewards[1].amount)));
    assert.isTrue(toBN(12E18).eq(toBN(rslt.voterRewards[2].amount)));
    
    let sm = toBN(rslt.remainder);
    for(const rwd of rslt.voteeRewards) sm = sm.add(toBN(rwd.amount));
    for(const rwd of rslt.voterRewards) sm = sm.add(toBN(rwd.amount));
    assert.isTrue(toBN(rwdPot.total).eq(sm));
    console.log(sm.toString());
  });


  it("Can calculate a scenario where all 3 votees have different scores.", async() => {
    
    const [chance, admin, rwdModel] = await prepareFixtures(true);
    const rwdPot = {total: toBN(1E20).toString(), contribsPercent: 70};

    const vts = [];           // votes
    vts.push({voter: voters[0], votee: votees[1], amount: toBN(7E18).toString()});  // voter1 -> A, 3ESV 
    vts.push({voter: voters[1], votee: votees[2], amount: toBN(3E18).toString()});  // voter2 -> A, 3ESV
    vts.push({voter: voters[2], votee: votees[0], amount: toBN(4E18).toString()});  // voter3 -> B, 4ESV
        
    const scrs = [];          // scores
    scrs.push({owner: votees[0], value: toBN(4E18).toString()});
    scrs.push({owner: votees[1], value: toBN(7E18).toString()});
    scrs.push({owner: votees[2], value: toBN(3E18).toString()});
    
    const rslt = await rwdModel.calcRewards(rwdPot, vts, scrs, floorAt);
    
    assert.equal(scrs.length, rslt.voteeRewards.length);
    assert.equal(vts.length, rslt.voterRewards.length);
    assert.isTrue(rslt.remainder.gtn(0));
    assert.isTrue(toBN(20E18).eq(toBN(rslt.voteeRewards[0].amount)));
    assert.isTrue(toBN(35E18).eq(toBN(rslt.voteeRewards[1].amount)));
    assert.isTrue(toBN(15E18).eq(toBN(rslt.voteeRewards[2].amount)));
    
    const rngs = [
      [toBN(18E18), toBN(18E18)],
      [toBN(5.14E18), toBN(5.15E18)],   // 5.1429...
      [toBN(6.85E18), toBN(6.86E18)] ]
    let amt = 0;
    for(let i = 0; i < rslt.voterRewards.length; i++){
      amt = toBN(rslt.voterRewards[i].amount);
      assert.isTrue(amt.gte(rngs[i][0]) && amt.lte(rngs[i][1]));
    }
    
    let sm = toBN(rslt.remainder);
    for(const rwd of rslt.voteeRewards) sm = sm.add(toBN(rwd.amount));
    for(const rwd of rslt.voterRewards) sm = sm.add(toBN(rwd.amount));
    assert.isTrue(toBN(rwdPot.total).eq(sm));
    console.log(sm.toString());
  });

});