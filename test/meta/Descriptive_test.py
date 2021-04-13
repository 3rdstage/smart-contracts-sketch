#!/usr/bin/python3

import pytest
import random

from brownie import accounts, Descriptive

# https://eth-brownie.readthedocs.io/en/stable/tests-pytest-fixtures.html#pytest-fixtures-reference
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contractcontainer
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contract-and-projectcontract


KEYS = ['color', 'height', 'width', 'weight', 'max', 'min', 'country', 'city']
COLORS = ['Black', 'White', 'Gray', 'Red', 'Green', 'Blue', 'Orange', 'Brown', 'Orange']


@pytest.fixture
def deployer():
  return accounts[0]

@pytest.fixture
def testee(deployer):
  return deployer.deploy(Descriptive)


def test_inital_state(testee):
  assert testee.getName() == ''
  
  for i in range(0, 5):
    key = random.choice(KEYS)
    assert testee.getAttribute(key) == ''
  

def test_set_attribute_singular(testee):
  color = random.choice(COLORS)
  testee.setAttribute("color", color)

  value = testee.getAttribute("color")
  assert value == color
  print(value)
  
  values = testee.getAttributes("color")
  assert len(values) == 1
  assert values[0] == color
  print(values)
  print(type(values))
  
