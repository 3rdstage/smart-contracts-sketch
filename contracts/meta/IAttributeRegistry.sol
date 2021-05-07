// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

// org.springframework.http.HttpHeaders API : https://docs.spring.io/spring-framework/docs/5.1.x/javadoc-api/index.html?org/springframework/http/HttpHeaders.html

struct Attribute{
    string name;
    string value;
}

interface IAttributeRegistry{

    event AttributeAdded(uint indexed id, string indexed name, string value, uint no);
    event AttributeRemoved(uint indexed id, string indexed name, string value);    
    event AttributesRemoved(uint indexed id, string indexed name);

    function getAttributeNames(uint id) external view returns (string[] memory);
    
    function getAttribute(uint id, string memory name) external view returns (string memory);

    function getAttributes(uint id, string memory name) external view returns (string[] memory);

    function getAttributesCount(uint id, string memory name) external view returns (uint);

    function setAttribute(uint id, string memory name, string memory value) external;
    
    function addAttribute(uint id, string memory name, string memory value) external;

    function removeAttribute(uint id, string memory name, string memory value) external;

    function removeAttributes(uint id, string memory name) external;

}
