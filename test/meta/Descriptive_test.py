#!/usr/bin/python3

import pytest
import random

from brownie import accounts, Descriptive

# https://eth-brownie.readthedocs.io/en/stable/tests-pytest-fixtures.html#pytest-fixtures-reference
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contractcontainer
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contract-and-projectcontract


COLORS = ['Black', 'White', 'Gray', 'Red', 'Green', 'Blue', 'Orange', 'Brown', 'Orange']


@pytest.fixture
def deployer():
  return accounts[0]

@pytest.fixture
def testee(deployer):
  return deployer.deploy(Descriptive)


def test_inital_state(testee):
  name = testee.getName()
  
  assert name == ''
  

def test_set_attribute_singular(testee):
  color = random.choice(COLORS)
  testee.setAttribute("color", color)
  
  values = testee.getAttribute("color")
  
  print(values)
  
  
  