pragma solidity ^0.6.0;

import './ERC20Regular.sol';

contract TypedAccountToken is ERC20Regular{

  mapping(address => bytes32) private accountToTypeMap;
  
  event AccountTypeAssigned(bytes32 indexed accountType, address account);

  constructor(string memory _name, string memory _symbol) public ERC20Regular(_name, _symbol){ }

  function assignAccountType(bytes32 _type, address _acct) external whenNotPaused onlyAdmin{
      accountToTypeMap[_acct] = _type;
      
      emit AccountTypeAssigned(_type, _acct);
  }
  
  function unassignAccountType(address _acct) external whenNotPaused onlyAdmin{
      delete accountToTypeMap[_acct];
  }

  function accountTypeOf(address _acct) public view returns (bytes32){ 
      
      return accountToTypeMap[_acct];
  }

}

