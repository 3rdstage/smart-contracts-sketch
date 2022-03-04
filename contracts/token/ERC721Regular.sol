// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../node_modules/@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol";

contract ERC721Regular is ERC721PresetMinterPauserAutoId{

    constructor(string memory name, string memory symbol) ERC721PresetMinterPauserAutoId(name, symbol, ""){
    }
    
    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }

}

