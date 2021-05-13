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
def erc721(deployer):
  return deployer.deploy(ERC721Mock, 'Card NFT', 'ABC', '')

@pytest.fixture
def testee(deployer, erc721):
  return deployer.deploy(SingleOriginAuction, erc721.address)


def test_initial_state(testee):
  n = testee.getAllOpenOffersCount()
  
  assert n == 0;


