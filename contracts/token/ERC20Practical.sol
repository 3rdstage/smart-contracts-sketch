pragma solidity ^0.6.0;


import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";


contract ERC20Practical is ERC20Burnable{

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) public { }

}

