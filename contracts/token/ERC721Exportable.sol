// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/extensions/ERC721URIStorage.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";

/**
 * @author Sangmoon Oh
 * @custom:since 2022-03-15
 */
contract ERC721Exportable is ERC721PresetMinterPauserAutoId, ERC721URIStorage {
    using EnumerableSet for EnumerableSet.UintSet;

    enum State { Exporting, Exported, Imported }

    mapping(State => EnumerableSet.UintSet) private _statedTokens;

    constructor(string memory name, string memory symbol) ERC721PresetMinterPauserAutoId(name, symbol, ""){
    }

    /**
     * Set a token into the specified state exclusively
     */
    function _toggleTokenState(uint256 tokenId, State state) internal {
        for(uint256 i = 0; i < 3; i++){
            if(State(i) == state) _statedTokens[state].add(tokenId);
            else _statedTokens[State(i)].remove(tokenId);
        }
    }

    /**
     * Only owner or approved of a token can start exporting the token.
     * 
     * @param escrowee the address to whom the token is temporarily owned while exporting (before exported.)
     */
    function exporting(uint256 tokenId, address escrowee) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Exportable: caller is not owner nor approved");
        _setExporting(tokenId, escrowee);
    }

    /**
     * @param escrowee the address to whom the token is temporarily owned while exporting (before exported.)
     */
    function _setExporting(uint256 tokenId, address escrowee) internal virtual {
        require(_exists(tokenId), "ERC721Exportable: Token to export dosen't exist or isn't in normal state.");

        // maybe redundant 
        require(!_isExporting(tokenId), "ERC721Exportable: Token is already in exporting.");
        _transfer(ownerOf(tokenId), escrowee, tokenId);
        _toggleTokenState(tokenId, State.Exporting);
    } 

    function _isExporting(uint256 tokenId) internal view returns(bool) {
        return _statedTokens[State.Exporting].contains(tokenId);
    }

    /**
     * Only token onwer can set the token exported (finished exporting).
     * 
     */ 
    function exported(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "ERC721Exportable: Minter role is required to set token exported");

        _setExported(tokenId);
    }

    function _setExported(uint256 tokenId) internal virtual {
        require(_isExporting(tokenId), "ERC721Exportable: Currently token is not exporting.");

        _burn(tokenId);
        _toggleTokenState(tokenId, State.Exported);
    }
 
    /**
     * Only token minter (who has MINTER role) can import a token
     *
     * @param owner a new owner of the specified token - shoudn't be zero address
     */
    function imported(uint256 tokenId, address owner) public {
        require(hasRole(MINTER_ROLE, msg.sender), "ERC721Exportable: Minter role is required to import a token");

        _import(tokenId, owner);
    }

    function _import(uint256 tokenId, address owner) public {
        require(owner != address(0), "ERC721Exportalbe: Can't import to zero address.");
        require(!_exists(tokenId), "ERC721Exportable: Token to import already exists.");
        require(!_isExporting(tokenId), "ERC721Exportable: Can't import a token in exporting");

        _mint(owner, tokenId);
        _toggleTokenState(tokenId, State.Imported);
    }


    function _countStatedTokens(State state) internal view returns(uint256){
        return _statedTokens[state].length();
    }

    function _getStatedTokens(State state) internal view returns(uint256[] memory){
        return _statedTokens[state].values();
    }

    /**
     * @return the number of tokens in exporting state
     */
    function countExportingTokens() public view returns(uint256){
        return _countStatedTokens(State.Exporting);
    }

    /**
     * @return the IDs of tokens in exporting state
     */
    function exportingTokens() public view returns(uint256[] memory){
        return _getStatedTokens(State.Exporting);
    }

    function countExportedTokens() public view returns(uint256){
        return _countStatedTokens(State.Exported);
    }

    function exportedTokens() public view returns(uint256[] memory){
        return _getStatedTokens(State.Exported);
    }

    function countImportedTokens() public view returns(uint256){
        return _countStatedTokens(State.Imported);
    }

    function importedTokens() public view returns(uint256[] memory){
        return _getStatedTokens(State.Imported);
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

    function setTokenURI(uint256 tokenId, string memory uri) public {
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage, ERC721) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721PresetMinterPauserAutoId, ERC721) returns (bool){
        return ERC721PresetMinterPauserAutoId.supportsInterface(interfaceId);
    }

}
