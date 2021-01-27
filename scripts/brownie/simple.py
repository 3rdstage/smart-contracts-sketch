from brownie import *

def main():
  
  n = web3.eth.blockNumber
  
  for i in range(n - 10, n + 1):
    m = len(web3.eth.getBlock(i, False).transactions)
    print(f'Block: {i:,} - Number of Transactions: {m:,}')
    for j in range(min(m, 10)):
      tx = web3.eth.getTransactionByBlock(i, j)
      to = tx.to
      val = tx.value
      to_code = web3.eth.getCode(to)[:100]
      if(val != 0):
        bal = web3.eth.getBalance(to, 'latest')
        print(f'Block: {i:,}, Tx: {j:,}, to: {to}, value: {val}, to.balance: {bal}, to.code: {to_code}')