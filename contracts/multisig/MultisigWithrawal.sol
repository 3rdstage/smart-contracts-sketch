// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

struct Withrawal {
  uint256 amount;
  address to;
}

// https://www.codementor.io/@beber89/build-a-basic-multisig-vault-in-solidity-for-ethereum-1tisbmy6ze
contract MultisigWithrawal{

  string constant private MSG_PREFIX = "\x19Ethereum Signed Message:\n32";
  mapping(address => bool) private _signers;
  uint256 private _threshold;
  uint256 public nonce;




}