// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../../node_modules/@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";

contract RegularERC20TokenL is ERC20PresetMinterPauser{
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/presets/ERC20PresetMinterPauser.sol

    constructor(string memory _name, string memory _symbol) public ERC20PresetMinterPauser(_name, _symbol){ }

    
}
