#!/usr/bin/python3

import pytest
import random

from brownie import accounts, Descriptive

# https://eth-brownie.readthedocs.io/en/stable/tests-pytest-fixtures.html#pytest-fixtures-reference
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contractcontainer
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contract-and-projectcontract


KEYS = ['color', 'height', 'width', 'weight', 'max', 'min', 'country', 'city']
COLORS = ['Black', 'White', 'Gray', 'Red', 'Green', 'Blue', 'Orange', 'Brown', 'Orange']
COUNTRIES = ['kr', 'us', 'jp', 'au', 'be', 'br', 'ca', 'cn', 'dk', 'fr']

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
  

def test_set_attribute(testee):
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
  

def test_add_attribute(testee):
  countries = random.choices(COUNTRIES, k=3)
  
  for cnt in countries:
    testee.addAttribute("countries", cnt)
    
  values = testee.getAttributes("countries")
  assert len(values) == 3
  for val in values:
    assert val in countries 
  print(values)
  

def test_get_attribute_names(testee):
  keys = ['color', 'width', 'height', 'weight', 'countries']
  
  testee.setAttribute(keys[0], random.choice(COLORS))
  testee.setAttribute(keys[1], "30")
  testee.setAttribute(keys[2], "40")
  testee.setAttribute(keys[3], "100")
  testee.addAttribute(keys[4], COUNTRIES[0])
  testee.addAttribute(keys[4], COUNTRIES[1])
  
  names = testee.getAttributeNames()
  assert len(names) == 5
  for nm in names:
    assert nm in keys
  print(names)
  
  
  