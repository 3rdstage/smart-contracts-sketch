// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;
//pragma experimental ABIEncoderV2; 


import "../../node_modules/@openzeppelin/contracts-4/utils/math/Math.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";


struct ColorFacet{
    string name;
    uint8 score;
}

contract ColoredBadge is ERC721PresetMinterPauserAutoId{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using Math for uint256;    

    //mapping(bytes32 => bytes) private _colors;
    EnumerableSet.Bytes32Set private _colorKeys;
    
    mapping(uint256 => mapping(bytes32 => uint256)) private _tokenColors;
    mapping(bytes32 => EnumerableSet.UintSet) private _tokensByColor;
    
    
    event TokenColored(uint256 indexed tokenId, string indexed color, uint8 score);
    

    constructor(string[] memory colors) public ERC721PresetMinterPauserAutoId('Test', 'TST', ''){
        
        uint256 n = colors.length;
        for(uint256 i = 0; i < n; i++){
            bytes32 key = bytes32(bytes(colors[i]));
            if(!_colorKeys.contains(key)) _colorKeys.add(key);
        }
    }

    function getAllColors() public view returns (string[] memory){
        
        uint256 n = _colorKeys.length();
        string[] memory colors = new string[](n);
        for(uint256 i = 0; i < n; i++){
            colors[i] = string(bytes.concat(_colorKeys.at(i)));
        }

        return colors;
    }
    
    function addColor(string memory color) public {
        
        bytes32 key = bytes32(bytes(color));
        require(!_colorKeys.contains(key), "Already included color");
        
        _colorKeys.add(key);
    }
    
    
    function setTokenColor(uint256 tokenId, string memory color, uint8 score) public{
        
        // @TODO Needs priviledge control
        require(score < 101, "Max for score is 100");
        _setTokenColor(tokenId, color, score);

    }

    function setTokenColors(uint256 tokenId, ColorFacet[] memory colors) public{

        ownerOf(tokenId); // check existence
        
        uint256 n = colors.length;
        require(n > 0, "No color specified.");
        for(uint256 i = 0; i < n; i++){
            require(colors[i].score < 101, "Max for score is 100");
            _setTokenColor(tokenId, colors[i].name, colors[i].score);
        }
           
    }
    
    function _setTokenColor(uint256 tokenId, string memory color, uint8 score) public{
        
        bytes32 key = bytes32(bytes(color));
        require(_colorKeys.contains(key), "Unrecognizable color");
        
        _tokenColors[tokenId][key] = score;
        emit TokenColored(tokenId, color, score);
    }
    
    
    function clearTokenColor(uint256 tokenId, string memory color) public{
        // @TODO
        
    }
    
    
    function getTokenColors(uint256 tokenId) public returns (ColorFacet[] memory){
        // @TODO
        ColorFacet[] memory facets;

        return facets;
    }

    function countTokensByColor(string memory color) public returns (uint256) {
        // @TODO
        return 0;
    }
    
    function findTokensByColor(string memory color, uint256 pageSize, uint256 pageNo) public returns (uint256[] memory){
        // @TODO
        uint256[] memory ids;
        
        return ids;
    }
    
    function findTokensByColor(string memory color, uint256 pageNo) public returns(uint256[] memory){
        // @TODO
        uint256[] memory ids;
        
        return ids;
    }

    
}