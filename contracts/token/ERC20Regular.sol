// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

// ERC20PresetMinterPauser.sol : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/presets/ERC20PresetMinterPauser.sol
// ERC20.sol : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/token/ERC20/ERC20.sol
// ERC20Burnable.sol : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/token/ERC20/ERC20Burnable.sol
// ERC20Pausable.sol : https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.1.0/contracts/token/ERC20/ERC20Pausable.sol

contract ERC20Regular is ERC20PresetMinterPauser{
    
  modifier onlyAdmin(){
      require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Aadmin role is required to do this");
      _;
  }

  constructor(string memory _name, string memory _symbol) public ERC20PresetMinterPauser(_name, _symbol){ }



}

