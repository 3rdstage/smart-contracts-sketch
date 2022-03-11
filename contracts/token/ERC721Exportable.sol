// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/extensions/ERC721URIStorage.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";

contract ERC721Exportable is ERC721PresetMinterPauserAutoId, ERC721URIStorage {
    using EnumerableSet for EnumerableSet.UintSet;

    enum State { Exporting, Exported}

    mapping(State => EnumerableSet.UintSet) private _statedTokens;

    constructor(string memory name, string memory symbol) ERC721PresetMinterPauserAutoId(name, symbol, ""){
    }
    
    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }

    function exporting(uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Exportable: caller is not owner nor approved");
        _setExporting(tokenId);
    }

    function _setExporting(uint256 tokenId) internal virtual {
        require(_exists(tokenId), "ERC721Exportable: Token to export dosen't exist or isn't in normal state.");

        // maybe redundant 
        require(!_isExporting(tokenId), "ERC721Exportable: Token is already in exporting.");
        _burn(tokenId);
        _statedTokens[State.Exporting].add(tokenId);
    } 

    function _isExporting(uint256 tokenId) internal view returns(bool) {
        return _statedTokens[State.Exporting].contains(tokenId);
    }

    function exported(uint256 tokenId) public {
        require(hasRole(MINTER_ROLE, msg.sender), "ERC721Exportable: Minter role is required to set token exported");

        _setExporting(tokenId);
    }

    function _setExported(uint256 tokenId) internal virtual {
        require(_isExporting(tokenId), "ERC721Exportable: Currently token is not exporting.");

        _statedTokens[State.Exporting].remove(tokenId);
        _statedTokens[State.Exported].add(tokenId);
    }

    function imported(uint256 tokenId, address owner) public {
        require(hasRole(MINTER_ROLE, msg.sender), "ERC721Exportable: Minter role is required to import a token");

        _import(tokenId, owner);
    }

    function _import(uint256 tokenId, address owner) public {
        require(owner != address(0), "ERC721Exportalbe: Can't import to zero address.");
        require(!_exists(tokenId), "ERC721Exportable: Token to import already exists.");
        require(!_isExporting(tokenId), "ERC721Exportable: Can't import a token in exporting");

        _mint(owner, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721URIStorage, ERC721) {
        ERC721URIStorage._burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721PresetMinterPauserAutoId, ERC721) {
        ERC721PresetMinterPauserAutoId._beforeTokenTransfer(from, to, tokenId);
    }

    function _baseURI() internal view virtual override(ERC721PresetMinterPauserAutoId, ERC721) returns (string memory) {
        return ERC721PresetMinterPauserAutoId._baseURI();
    } 

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage, ERC721) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721PresetMinterPauserAutoId, ERC721) returns (bool){
        return ERC721PresetMinterPauserAutoId.supportsInterface(interfaceId);
    }

    

}
