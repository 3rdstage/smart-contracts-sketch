// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/Context.sol";

contract MultisigSecureToken{

  mapping(address => uint256) private _balances;

  uint8 private _threshold = 2;

  MultisigLounge private multisig;


  function forceTransfer(address from, address to, uint256 amount) public{
    if(_threshold > 1){

      multisig.addTx();

    }else{
      _transfer(from, to, amount);
    }

  }

  function _transfer(address from, address to, uint256 amount) internal{

  }



}


contract MultisigLounge is Context{
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 private _no = 1;

  EnumerableSet.AddressSet private _admins;

  EnumerableSet.AddressSet private _members;

  mapping(address => mapping(address => bool)) private _signers;

  constructor(){
    _admins.add(_msgSender());
  }

  modifier onlyAdmin(){
    require(_admins.contains(_msgSender()), "Allowed for only admins.");
    _;
  }

  modifier onlyMember(){
    require(_members.contains(_msgSender()), "Allowed for only members.");
  }

  function grantAdmin(address acct) external onlyAdmin(){
    _admins.add(acct);
  }

  function revokeAdmin(address acct) external onlyAdmin(){
    _admins.remove(acct);
    require(_admins.length() > 0, "Last admin can't removed.");
  }

  function adminCount() public view returns(uint256){
    return _admins.length();
  }

  function isAdmin(address acct) public view returns(bool){
    return _admins.contains(acct);
  }

  function addMember(address contr) external onlyAdmin(){
    _members.add(contr);
  }


  function addTx() external onlyMember() returns(uint256 no){

    return _no++;
  }

  function confirmTx(uint256 no) external onlyMember()
      returns(uint256 confirms, uint256 remains){


  }

  function rejectTx(uint256 no) external onlyMember()
      returns(uint256 confirms, uint256 remains){

  }

  function revokeTx(uint256 no) external onlyMember()
      returns(uint256 confirms, uint256 remains){

  }

  function removeTx(uint256 no) external onlyMember() {

  }

  function countTx() public view returns(uint256){

  }

  function list10(uint256 s) public{


  }


}