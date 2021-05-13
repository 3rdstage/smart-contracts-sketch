// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";

contract ERC721Mock is ERC721PresetMinterPauserAutoId{
    
    constructor(string memory name, string memory symbol, string memory baseTokenURI) public ERC721PresetMinterPauserAutoId(name, symbol, baseTokenURI){ }

}