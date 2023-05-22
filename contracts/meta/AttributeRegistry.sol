// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "./IAttributeRegistry.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";


// org.springframework.http.HttpHeaders API : https://docs.spring.io/spring-framework/docs/5.1.x/javadoc-api/index.html?org/springframework/http/HttpHeaders.html

// @TODO Who can change attributes ?
// @TODO What if a duplicate pair of name/value is to be added ?
// @TODO For multiple values for a name(key), `Attribute.name`s are redundant.

contract AttributeRegistry is IAttributeRegistry{
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;

    mapping(uint => Attribute[]) private _attribs;  // id => attributes mapping
    mapping(uint => mapping(string => EnumerableSet.UintSet)) private _idxsByName;  // id => attribute name => attribute indexes
    mapping(uint => EnumerableSet.UintSet) private _firstIdxs;  // attribute indexes on first values for each name

    function getAttributeNames(uint id) public view override returns (string[] memory){
        uint l = _firstIdxs[id].length();

        string[] memory names = new string[](l);
        for(uint i = 0; i < l; i++){
            names[i] = _attribs[id][_firstIdxs[id].at(i)].name;
        }

        return names;
    }


    function getAttribute(uint id, string memory name) public view override returns (string memory){
        uint m = _idxsByName[id][name].length();
        string memory val;
        if(m > 0) val = _attribs[id][_idxsByName[id][name].at(0)].value;

        return val;
    }


    function getAttributes(uint id, string memory name) public view override returns (string[] memory){
        uint m = _idxsByName[id][name].length();
        string[] memory vals = new string[](m);

        for(uint i = 0; i < m; i++){
            vals[i] = _attribs[id][_idxsByName[id][name].at(i)].value;
        }

        return vals;
    }

    function getAttributesCount(uint id, string memory name) public view override returns (uint){
        return _idxsByName[id][name].length();
    }

    function setAttribute(uint id, string memory name, string memory value) public override{
        _removeAttributes(id, name);
        _addAttribute(id, name, value);
    }

    function addAttribute(uint id, string memory name, string memory value) public override{
        _addAttribute(id, name, value);
    }

    function _addAttribute(uint id, string memory name, string memory value) internal{
        uint idx = _attribs[id].length;
        _attribs[id].push(Attribute(name, value));
        _idxsByName[id][name].add(idx);
        uint n = _idxsByName[id][name].length();

        if(n == 1) _firstIdxs[id].add(idx);
        emit AttributeAdded(id, name, value, _idxsByName[id][name].length());

    }


    function removeAttribute(uint id, string memory name, string memory value) public override{

        uint m = _idxsByName[id][name].length();
        if(m == 0) return;

        bytes32 hash = keccak256(abi.encodePacked(value));
        string memory val;
        uint idx;
        for(uint i = 0; i < m; i++){
            idx = _idxsByName[id][name].at(i);
            val = _attribs[id][idx].value;
            if(keccak256(abi.encodePacked(val)) == hash){
                delete _attribs[id][idx];
                _idxsByName[id][name].remove(idx);
                if(_firstIdxs[id].contains(idx)){
                    _firstIdxs[id].remove(idx);
                    if(_idxsByName[id][name].length() > 0){
                        _firstIdxs[id].add(_idxsByName[id][name].at(0));
                    }
                }
                emit AttributeRemoved(id, name, value);
            }
        }

    }

    function removeAttributes(uint id, string memory name) public override{
        _removeAttributes(id, name);

    }

    function _removeAttributes(uint id, string memory name) internal{
        uint m = _idxsByName[id][name].length();

        if(m > 0){
            uint idx;
            for(uint i = 0; i < m; i++){
                idx = _idxsByName[id][name].at(i);
                delete _attribs[id][idx];
                _firstIdxs[id].remove(idx);
            }

            delete _idxsByName[id][name];
            emit AttributesRemoved(id, name);
        }
   }

}

