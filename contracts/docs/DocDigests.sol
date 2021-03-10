// SPDX-License-Identifier: UNLICENSED
pragma abicoder v2;
pragma solidity ^0.7.0;

struct DocDigest{
    
    bytes hash;
    string algorithm;
    string title;
    string format;
    string filename;
    string url;
       
    address provider;
    
}

contract DocDigests {
    
    // main storage, `doc-id::uint256` -> `doc-digest`
    mapping(uint256 => DocDigest) private docs;
    
    // index storage, `doc-provider` -> `doc-id[]`
    mapping(address => uint256[]) private docsByProvider;
    
    
    
    function addDoc(DocDigest memory doc) public{
          
    }
    
    
    
    
    
    
    
    
}