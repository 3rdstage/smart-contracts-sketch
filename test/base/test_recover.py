#!/usr/bin/python3

from typing import Union
from hexbytes import HexBytes
from eth_keys import keys
from eth_account import Account
from eth_account.messages import encode_defunct
from eth_account._utils.signing import to_standard_signature_bytes
from eth_utils.curried import keccak
from eth_typing import Hash32

def recover_pubkey(message : str, signature: Union[str, HexBytes]) -> HexBytes:
  
  if isinstance(signature, str) :
    sig = HexBytes.fromhex(signature[2::] if signature.startswith('0x') else signature)
  else :
    sig = signature
  
  msg_191 = keccak(
    text='\x19Ethereum Signed Message:\n' + str(len(message)) + message)
  sig_std = to_standard_signature_bytes(sig)
  
  # recovering public key of secp256k1 keypair using `eth_keys` package
  pk_re = keys.Signature(sig_std).recover_public_key_from_msg_hash(Hash32(msg_191))
  
  print(f'recovered public key : {pk_re.to_hex()}')

  return HexBytes.fromhex(pk_re.to_hex()[2::])



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
  
  # private key of accounts[0] - configured to local ganache-cli
  sk = keys.PrivateKey(bytes.fromhex(
    '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e'[2::]))
  print(f'privat key : {sk.to_hex()}')
  print(f'public key : {sk.public_key.to_hex()}')
  print(f'address    : {sk.public_key.to_address()}')
  
  assert sk.public_key.to_address().upper() == accounts[0].address.upper()
  
  msg = 'We built this city.'
  sig = web3.eth.sign(accounts[0].address, text=msg) # HexBytes
  print(f'message    : {msg}')
  print(f'ethereum signature  : {sig.hex()}')
  
  # recover address (not public key) using `eth_account.account.Account.recover_message`
  addr_re=Account.recover_message(encode_defunct(text=msg), signature=sig)
  
  assert addr_re.upper() == sk.public_key.to_address().upper()
  print(f'address recovered from signature : {addr_re} - same with the above value')
  
  # EIP-191 (https://eips.ethereum.org/EIPS/eip-191) defines preproessing 
  #         on original message before appyling standard signing of ECDSA.
  msg_191 = keccak(text='\x19Ethereum Signed Message:\n' + str(len(msg)) + msg)
  print(f'EIP-191 applied message : {"0x" + msg_191.hex()}')
  sig_std = to_standard_signature_bytes(sig)
  
  # recovering public key of secp256k1 keypair using `eth_keys` package
  pk_re = keys.Signature(sig_std).recover_public_key_from_msg_hash(Hash32(msg_191))
  
  assert pk_re.to_hex().upper() == sk.public_key.to_hex().upper()
  print(f'''public key recovered from signature : 
            {pk_re.to_hex()} - same with the above value''')


  
def test_recover_pubkey_function(accounts, web3):

  sk = keys.PrivateKey(bytes.fromhex(
    '0x052fdb8f5af8f2e4ef5c935bcacf1338ad0d8abe30f45f0137943ac72f1bba1e'[2::]))
  print(f'public key : {sk.public_key.to_hex()}')


  def test(msg):
    sig = web3.eth.sign(accounts[0].address, text=msg)
    print('\n')
    print(f'message              : {msg}')
    print(f'ethereum signature   : {sig}')

    pk = recover_pubkey(msg, sig)
    
    assert pk.hex() == sk.public_key.to_hex()
    print(f'recovered public key : {pk.hex()}')
    
  test('Life is Live')
  test('12345^&*()     abcdeFGHIJ')
  test('내 마음 깊은 곳의 너')
  
