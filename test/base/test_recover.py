#!/usr/bin/python3

from eth_keys import keys
from eth_account import Account
from eth_account.messages import encode_defunct
from eth_account._utils.signing import to_standard_signature_bytes
from eth_utils.curried import keccak
from eth_typing import Hash32

def test_hello():
  print("Hello !")
  

# References
#   - web3.py API : https://web3py.readthedocs.io/en/stable/web3.eth.html
#   - eth_keys API : https://github.com/ethereum/eth-keys/#documentation
#   - eth_account API : https://eth-account.readthedocs.io/en/stable/eth_account.html
#   - eth_account.account.Account._recover_hash() 
#       : https://github.com/ethereum/eth-account/blob/v0.5.4/eth_account/account.py#L428
#   - EIP-191 Signed Data Standard : https://eips.ethereum.org/EIPS/eip-191  
def test_recover_pubkey(accounts, web3):
  
  prvkey = keys.PrivateKey(bytes.fromhex(
    '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e'[2::]))
  print(f'privat key : {prvkey.to_hex()}')
  print(f'public key : {prvkey.public_key.to_hex()}')
  print(f'address    : {prvkey.public_key.to_address()}')
  
  msg = 'We built this city.'
  sig = web3.eth.sign(accounts[0].address, text=msg) # HexBytes
  print(f'message    : {msg}')
  print(f'signature  : {sig.hex()}')
  
  # recover address (not public key) using `eth_account.account.Account.recover_message`
  addr_re=Account.recover_message(encode_defunct(text=msg), signature=sig)
  
  assert addr_re.upper() == prvkey.public_key.to_address().upper()
  print(f'address recovered from signature : {addr_re} - same with the above value')
  
  # EIP-191 (https://eips.ethereum.org/EIPS/eip-191) defines preproessing 
  #         on original message before appyling standard signing of ECDSA.
  msg_191 = keccak(text='\x19Ethereum Signed Message:\n' + str(len(msg)) + msg)
  sig_std = to_standard_signature_bytes(sig)
  
  # recovering public key of secp256k1 keypair using `eth_keys` package
  pubkey_re = keys.Signature(sig_std).recover_public_key_from_msg_hash(Hash32(msg_191))
  
  assert pubkey_re.to_hex().upper() == prvkey.public_key.to_hex().upper()
  print(f'''public key recovered from signature : 
            {pubkey_re.to_hex()} - same with the above value''')

  