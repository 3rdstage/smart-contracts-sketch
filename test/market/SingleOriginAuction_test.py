#!/usr/bin/python3

import pytest
import random

from brownie import accounts, SingleOriginAuction, ERC721Mock

# https://eth-brownie.readthedocs.io/en/stable/tests-pytest-fixtures.html#pytest-fixtures-reference
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contractcontainer
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contract-and-projectcontract


@pytest.fixture
def deployer():
  return accounts[0]


@pytest.fixture
def testee(deployer):
  return deployer.deploy(SingleOriginAuction)



def test_initial_state(testee):
  n = testee.findAllOpenOffersCount()
  
  assert n == 0;


