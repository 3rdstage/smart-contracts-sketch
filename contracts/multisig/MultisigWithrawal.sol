// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/utils/cryptography/ECDSA.sol";

struct Withdrawal {
  uint256 amount;
  address to;
}

// https://www.codementor.io/@beber89/build-a-basic-multisig-vault-in-solidity-for-ethereum-1tisbmy6ze
contract MultisigWithdrawal{

  string constant private MSG_PREFIX = "\x19Ethereum Signed Message:\n32";
  mapping(address => bool) private _signers;
  uint256 private _threshold;
  uint256 public _nonce;

  bool private _lock;
  modifier nonReentrant(){
    require(!_lock);
    _lock = true;
    _;
    _lock = false;
  }

  constructor(address[] memory signers){

    _threshold = signers.length;
    for(uint i = 0; i < _threshold; i++){
      _signers[signers[i]] = true;
    }
  }

  function _digestWithdrawal(Withdrawal calldata tx_, uint256 nonce) private pure returns(bytes32 digest){
    bytes memory encoded = abi.encode(tx_);
    digest = keccak256(abi.encodePacked(encoded, nonce));
    digest = keccak256(abi.encodePacked(MSG_PREFIX, digest));
  }

  function _verifySignatures(Withdrawal calldata tx_,
      uint256 nonce, bytes[] calldata signatures) private {

    require(nonce > _nonce, "Nonce already used.");
    uint256 cnt = signatures.length;
    require(cnt >= _threshold, "Not enough signers.");
    bytes32 digest = _digestWithdrawal(tx_, nonce);

    address initSigner;
    for(uint256 i = 0; i < cnt; i++){
      bytes memory signature = signatures[i];
      address signer = ECDSA.recover(digest, signature);
      require(signer > initSigner, "Possible duplicate");
      require(_signers[signer], "Not valid signer");
      initSigner = signer;
    }
    _nonce = nonce;
  }

  function _transfer(Withdrawal calldata tx_) private{
    (bool success, ) = payable(tx_.to).call{value: tx_.amount}("");
    require(success, "Transfer failed.");
  }

  function transfer(Withdrawal calldata tx_, uint256 nonce,
      bytes[] calldata signatures) external nonReentrant{

    _verifySignatures(tx_, nonce, signatures);
    _transfer(tx_);

  }

}