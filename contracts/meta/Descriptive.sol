// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";


// org.springframework.http.HttpHeaders API : https://docs.spring.io/spring-framework/docs/5.1.x/javadoc-api/index.html?org/springframework/http/HttpHeaders.html

struct Attribute{
    string name;
    string value;
}

// @TODO Who can change attributes ?

contract Descriptive{
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;

    Attribute[] private _attribs;
    mapping(string => EnumerableSet.UintSet) private _idxsByName; // attrib name => attrib indexes
    EnumerableSet.UintSet private _firstIdxs;  // attrib indexes on first values for each name

    string[2] private aliases;

    string private _name;

    event AttributeSet(string indexed name, string value, uint indexed index);
    event AttributeAdded(string indexed name, string value, uint count, uint indexed index);

    function getName() public view returns (string memory){
        return _name;
    }

    function setName(string memory name) public{
        _name = name;
    }

    function getAttribute(string memory name) public view returns (string memory){
        uint m = _idxsByName[name].length();
        string memory val;
        if(m > 0) val = _attribs[_idxsByName[name].at(0)].value;

        return val;
    }

    function getAttributes(string memory name) public view returns (string[] memory){
        uint m = _idxsByName[name].length();
        string[] memory vals = new string[](m);

        for(uint i = 0; i < m; i++){
            vals[i] = _attribs[_idxsByName[name].at(i)].value;
        }

        return vals;
    }

    function setAttribute(string memory name, string memory value) public{
        uint m = _idxsByName[name].length();
        if(m > 0){
            _firstIdxs.remove(_idxsByName[name].at(0));
            for(uint i = 0; i < m; i++){
                delete _attribs[_idxsByName[name].at(i)];
            }
        }

        delete _idxsByName[name];

        _addAttribute(name, value);
    }

    function addAttribute(string memory name, string memory value) public{
        _addAttribute(name, value);
    }

    function _addAttribute(string memory name, string memory value) internal{
        uint n = _attribs.length;
        _attribs.push(Attribute(name, value));
        _idxsByName[name].add(n);
        if(_idxsByName[name].length() == 1){
          _firstIdxs.add(n);
          emit AttributeSet(name, value, n);
        }else{
          emit AttributeAdded(name, value, _idxsByName[name].length(), n);
        }

    }

    function getAttributeNames() public view returns (string[] memory){
        uint l = _firstIdxs.length();

        string[] memory names = new string[](l);
        for(uint i = 0; i < l; i++){
            names[i] = _attribs[_firstIdxs.at(i)].name;
        }

        return names;
    }

    function removeAttribute(string memory name, string memory value) public{
        uint m = _idxsByName[name].length();

        if(m == 0) return;

        bytes32 hash = keccak256(abi.encodePacked(value));
        string memory val;
        uint idx;
        for(uint i = 0; i < m; i++){
            idx = _idxsByName[name].at(i);
            val = _attribs[idx].value;
            if(keccak256(abi.encodePacked(val)) == hash){
                delete _attribs[idx];
                _idxsByName[name].remove(idx);
                if(_firstIdxs.contains(idx)){
                    _firstIdxs.remove(idx);
                    if(_idxsByName[name].length() > 0){
                        _firstIdxs.add(_idxsByName[name].at(0));
                    }
                }
            }
        }

    }

    function removeAttributes(string memory name) public{
        uint m = _idxsByName[name].length();

        if(m == 0) return;

        uint idx;
        for(uint i = 0; i < m; i++){
            idx = _idxsByName[name].at(i);
            delete _attribs[idx];
            _idxsByName[name].remove(idx);
            _firstIdxs.remove(idx);
        }

    }

}

