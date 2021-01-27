from brownie import *

def main():
  
  n = web3.eth.blockNumber
  
  # for each block
  for i in range(min(n, 1000) + 1):
    blk = web3.eth.getBlock(i, False)
    blk_hash = blk.hash.hex()
    blk_epoch = blk.timestamp
    blk_txs = len(blk.transactions)
    
    print(f'Block - no: {i:,}, hash: {blk_hash}, epoch: {blk_epoch}, # of tx: {blk_txs}')