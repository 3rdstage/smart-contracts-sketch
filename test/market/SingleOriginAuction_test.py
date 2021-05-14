#!/usr/bin/python3

import pytest
import random
import time

from brownie import accounts, SingleOriginAuction, ERC721Mock

# https://eth-brownie.readthedocs.io/en/stable/tests-pytest-fixtures.html#pytest-fixtures-reference
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contractcontainer
# https://eth-brownie.readthedocs.io/en/stable/api-network.html#contract-and-projectcontract


@pytest.fixture
def deployer():
  return accounts[0]

@pytest.fixture
def admin():
  return accounts[0]

@pytest.fixture
def erc721(deployer):
  return deployer.deploy(ERC721Mock, 'Card NFT', 'ABC', '')

@pytest.fixture
def auction(deployer, erc721):
  return deployer.deploy(SingleOriginAuction, erc721.address)


def test_initial_state(auction):
  n = auction.getAllOpenOffersCount()
  
  assert n == 0;


def test_get_open_offers_count(erc721, auction, admin):
  
  offerers = accounts[1:6]
  lowestPrice = random.randint(1000, 10000)
  closedAt = int(time.time()) + 3600 * 24 * 10
  
  for i, offerer in enumerate(offerers):
    tx = erc721.mint(offerer, {'from': admin})
    assetId = tx.events['Transfer']['tokenId']
    print(offerer.address, assetId)
  
    auction.offer(assetId, lowestPrice, closedAt, {'from': offerer})
    
    assert auction.getAllOpenOffersCount() == (i + 1)


def test_find_offer(erc721, auction, admin):
  
  offerers = accounts[1:6]
  offerIds = []
  lowestPrice = random.randint(1000, 10000)
  closedAt = int(time.time()) + 3600 * 24 * 10
  
  for i, offerer in enumerate(offerers):
    tx = erc721.mint(offerer, {'from': admin})
    assetId = tx.events['Transfer']['tokenId']
    print(offerer.address, assetId)
    
    tx = auction.offer(assetId, lowestPrice, closedAt, {'from': offerer})
    offerIds.append(tx.events['OfferMade']['offerId'])
    
  for id in offerIds:
    offer = auction.findOffer(id);
    print(offer)
    assert offerIds.count(offer['id']) == 1
    assert offer['lowestPrice'] == lowestPrice
    assert offer['closedAt'] == closedAt
    assert offer['isWithdrawn'] == False
    assert offer['isOpen']

  


