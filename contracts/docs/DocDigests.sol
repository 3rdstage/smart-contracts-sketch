// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


struct DocDigest{
    
    bytes hash;
    string algorithm;
    string title;
    string format;
   
    address provider;
    
}

contract DocDigests {
    
    // main storage, `doc-id::uint256` -> `doc-digest`
    mapping(uint256 => DocDigest) private digests;
    
    // index storage, `doc-provider` -> `doc-id[]`
    mapping(address => uint256[]) private docsByProvider;
    
    
    
    
    
    
    
}