// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.0 <0.8.0;


import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/math/Math.sol";


// org.springframework.http.HttpHeaders API : https://docs.spring.io/spring-framework/docs/5.1.x/javadoc-api/index.html?org/springframework/http/HttpHeaders.html

struct Attribute{
    string name;
    string value;
}


contract Descriptive{
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;

    Attribute[] private attribs;
    mapping(string => EnumerableSet.UintSet) private attribsByName; // attrib name => attribs
    
    

    string private name;
    
    event AttributeSet(string indexed name, string value, uint indexed index);
    
    function getName() public view returns (string memory){
        return name;
    }
    
    function setName(string memory _name) public{
        name = _name;
    }
    
    function getAttribute(string memory _name) public view returns (string memory){
        uint n = attribsByName[_name].length();
        string memory val;
        if(n > 0) val = attribs[attribsByName[_name].at(0)].value;
        
        return val;
    }
    
    function getAttributes(string memory _name) public view returns (string[] memory){

        uint n = attribsByName[_name].length();
        string[] memory vals = new string[](n);
        
        for(uint i = 0; i < n; i++){
            vals[i] = attribs[attribsByName[_name].at(i)].value;
        }
        
        return vals;
    }
    
    function setAttribute(string memory _name, string memory _value) public{
        uint n = attribsByName[_name].length();
        for(uint i = 0; i < n; i++){
            delete attribs[attribsByName[_name].at(i)];
        }

        delete attribsByName[_name];
        uint idx = attribs.length;
        attribsByName[_name].add(idx);
        attribs.push(Attribute(_name, _value));
        
        emit AttributeSet(_name, _value, idx);
    }
    
    function addAttribute(string memory _name, string memory _value) public{

    }
    
    function getAttributeNames() public view returns (string[] memory){
        
    }
    
    function removeAttribute(string memory _name, string memory _value) public{
        
    }
    
    function removeAttributes(string memory _name) public{
        
    }
    
    

    
}

