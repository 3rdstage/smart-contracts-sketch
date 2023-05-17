// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// https://solidity-by-example.org/app/multi-sig-wallet/

contract MultisigTransfer{

  // Transaction State-chart
  //
  // [Not Confirmed] --+--> [Confirmed] --+---> [Executed]
  //                   |                  |
  //                   |                  |
  //                   +------------------+
  //
  // [Waiting] ---> [Executed]
  // [Waiting] : [Confirmed (by me)] | [Not Confirmed (by me)]


  event Deposit(address indexed sender, uint256 amount, uint256 balance);
  event Submit(
    address indexed owner,
    uint256 indexed txNo,
    address indexed to,
    uint256 value,
    bytes data
  );

  event Confirm(address indexed owner, uint256 indexed txNo);
  event Revoke(address indexed owner, uint256 indexed txNo);
  event Execute(address indexed owner, uint256 indexed txNo);

  address[] private _owners;
  mapping(address => bool) private _isOwner;
  uint256 private _threshold;

  struct Transaction{
    address to;
    uint256 value;
    bytes data;
    bool executed;
    uint confirms;
  }

  Transaction[] private _txs;
  // tx no => owner => bool
  mapping(uint256 => mapping(address => bool)) private _isConfirmed;

  modifier onlyOwner(){
    require(_isOwner[msg.sender], "Allowed only for owners");
    _;
  }

  modifier exists(uint256 txNo){
    require(txNo < _txs.length, "Nonexistent transaction");
    _;
  }

  modifier notExecuted(uint256 txNo){
    require(!_txs[txNo].executed, "Already executed transaction");
    _;
  }

  modifier notConfirmed(uint256 txNo){
    require(!_isConfirmed[txNo][msg.sender], "Already confirmed transaction");
    _;

  }

  constructor(address[] memory owners, uint256 threshold){
    require(threshold > 0, "Invalid threshold");
    require(owners.length > threshold, "Not enough owners");

    for(uint256 i = 0; i < owners.length; i++){
      address owner = owners[i];
      require(owner != address(0), "Zero address can't be an owner");
      require(!_isOwner[owner], "Owner duplicated.");

      _isOwner[owner] = true;
      _owners.push(owner);
    }

    _threshold == threshold;

  }

  receive() external payable{
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }

  function submitTx(
    address to, uint256 amount, bytes memory data) public onlyOwner{

    uint256 txNo = _txs.length;

    _txs.push(Transaction(to, amount, data, false, 0));

    emit Submit(msg.sender, txNo, to, amount, data);

  }

  function confirmTx(uint256 txNo)
    public onlyOwner exists(txNo)
      notExecuted(txNo) notConfirmed(txNo){

    Transaction storage tx_ = _txs[txNo];


  }

}