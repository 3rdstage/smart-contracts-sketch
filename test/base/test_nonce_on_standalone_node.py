import time
import pprint

def test_nonce_for_node_siginig(accounts, web3):
  
  if len(accounts) < 2 :
    assert 0, "At least 2 accounts should be available."
  
  sender = accounts[0]
  receiver = accounts[1]
  amt = 1000
  
  bal = web3.eth.getBalance(sender.address)
  
  if bal < 1000 * amt : 
    assert 0, "First account should have enough balance, maybe more than 1,000,000 wei"
    
  cnt = 3
  nc = web3.eth.getTransactionCount(sender.address);
  print(f'Sender\'s nonce before transactions : {nc}')
  
  hashes = []
  for i in range(0, cnt):
    hash = web3.eth.sendTransaction({'from': f'{sender.address}', 'to': f'{receiver.address}', 'value': f'{amt}'})
    hashes.append(hash)
    print(f'Transaction sent : {hash.hex()}')
  
  nc = web3.eth.getTransactionCount(sender.address);
  print(f'Sender\'s right after {cnt} transactions but before being mined : {nc}')
  
  blk_no = None
  pp = pprint.PrettyPrinter(indent=2)
  for hash in hashes:
    while True : 
      tx = web3.eth.getTransaction(hash)
      if tx.blockNumber is None:
        time.sleep(1)
      else:
        break;  
    pp.pprint(tx)
    
  nc = web3.eth.getTransactionCount(sender.address);
  print(f'Sender\'s after {cnt} transactions are mined : {nc}')


    