// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/extensions/ERC721URIStorage.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";
import "./IERC721Exportable.sol";

/**
 * @author Sangmoon Oh
 * @custom:since 2022-03-15
 */
contract ERC721Exportable is ERC721PresetMinterPauserAutoId, ERC721URIStorage, IERC721Exportable {
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

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
    function exporting(uint256 tokenId, address escrowee) public override{
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
    function exported(uint256 tokenId) public override{
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
    function imported(uint256 preferredTokenId, address owner) public override returns(uint256 tokenId) {
        require(hasRole(MINTER_ROLE, msg.sender), "ERC721Exportable: Minter role is required to import a token");

        return _import(preferredTokenId, owner);
    }

    function _import(uint256 preferredTokenId, address owner) private returns(uint256 tokenId) {
        require(owner != address(0), "ERC721Exportalbe: Can't import to zero address.");

        tokenId = preferredTokenId;
        if(_exists(preferredTokenId)){
            mint(owner);
            tokenId = _tokenIdTracker.current();
        }else{
            _mint(owner, tokenId);
        }

        _toggleTokenState(tokenId, State.Imported);
        return tokenId;
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
    function countExportingTokens() public view override returns(uint256){
        return _countStatedTokens(State.Exporting);
    }

    /**
     * @return the IDs of tokens in exporting state
     */
    function exportingTokens() public view override returns(uint256[] memory){
        return _getStatedTokens(State.Exporting);
    }

    function countExportedTokens() public view override returns(uint256){
        return _countStatedTokens(State.Exported);
    }

    function exportedTokens() public view override returns(uint256[] memory){
        return _getStatedTokens(State.Exported);
    }

    function countImportedTokens() public view override returns(uint256){
        return _countStatedTokens(State.Imported);
    }

    function importedTokens() public view override returns(uint256[] memory){
        return _getStatedTokens(State.Imported);
    }

    function mint(address to) public virtual override{
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
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
        // TODO check permission
        
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage, ERC721) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721, ERC721PresetMinterPauserAutoId) returns (bool){
        return ERC721PresetMinterPauserAutoId.supportsInterface(interfaceId);
    }
}
