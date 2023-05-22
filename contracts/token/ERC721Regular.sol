// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//import "../../node_modules/@openzeppelin/contracts-4/token/erc721/extensions/ERC721URIStorage.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract ERC721Regular is ERC721PresetMinterPauserAutoId{

    constructor(string memory name, string memory symbol) ERC721PresetMinterPauserAutoId(name, symbol, ""){
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {
        // @TODO
        //_setTokenURI(tokenId, uri);
    }

}

