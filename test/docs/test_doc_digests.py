#!/usr/bin/python3

import pytest
import random

from brownie import accounts, DocDigests

@pytest.fixture
def deployer():
  return accounts[0]

@pytest.fixture
def testee(deployer):
  return deployer.deploy(DocDigests)

def test_initial_state(testee):
  accts = random.choices(accounts, k = min(len(accounts), 3))
  
  for acct in accts:
    assert testee.countDocsByRegistar(acct.address) == 0;
    assert testee.countDocsByStakeholder(acct.address) == 0;


