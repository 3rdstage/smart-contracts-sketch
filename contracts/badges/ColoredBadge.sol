// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2; 


import "../../node_modules/@openzeppelin/contracts-4/utils/math/Math.sol";
import "../../node_modules/@openzeppelin/contracts-4/utils/structs/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts-4/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract ColoredBadge is ERC721PresetMinterPauserAutoId{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using Math for uint256;    

    mapping(bytes32 => bytes) private _colors;
    EnumerableSet.Bytes32Set private _colorKeys;
    
    mapping(uint256 => mapping(bytes32 => uint256)) private _assetColors;
    mapping(bytes32 => EnumerableSet.UintSet) private _assetsByColor;

    constructor(string memory name, string memory symbol, string memory baseURI, string[] memory colors) public ERC721PresetMinterPauserAutoId(name, symbol, baseURI){
        
        uint256 n = colors.length;
        for(uint256 i = 0; i < n; i++){
            bytes memory color = bytes(colors[i]);
            bytes32 key = keccak256(color);
            if(!_colorKeys.contains(key)){
                _colorKeys.add(key);
                _colors[key] = color;
            }
        }
    }

    function getAllColors() public view returns (string[] memory){
        
        uint256 n = _colorKeys.length();
        string[] memory colors = new string[](n);
        for(uint256 i = 0; i < n; i++){
            colors[i] = string(_colors[_colorKeys.at(i)]);
        }

        return colors;
    }
    
    
}