from brownie import *

def main():
  print('Hello, World')
  
  n = web3.eth.blockNumber
  
  for i in range(n - 10, n + 1):
    m = len(web3.eth.getBlock(i, False).transactions)
    print(f'Block: {n:,} - Number of Transactions: {m:,}')