// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity ^0.7.5;

struct DocDigest{

    bytes hash;
    string algorithm;
    
    string title;
    string format;
    string filename;
    string url;
    // poId ?
           
    address registar;
    
    address[] stakeholders;
}


contract DocDigests {
    
    // main storage, `doc-id::uint256` -> `doc-digest`
    mapping(uint256 => DocDigest) private docs;
    
    // index storage, `doc-provider` -> `doc-id[]`
    mapping(address => uint256[]) private docsByRegistar;
    
    mapping(address => uint256[]) private docsByStakeholder;

    event DocAdded(uint256 indexed id, bytes32 no, address registar, bytes hash);

    
    function addDoc(string memory title, string memory format, 
        string memory filename, string memory url, bytes memory hash, string memory algrthm,
        address[] memory stakeholders) public{
            
        bytes32 no = keccak256(abi.encodePacked(title, format, filename, block.timestamp));
        
        // truncate left(more significant) and convert to uint
        uint256 id = uint64(bytes8(no));
        
        // @TODO retry with slightly diffrent value when id duplicates

        DocDigest memory doc = DocDigest(hash, algrthm, title, format, filename, url, msg.sender, stakeholders);
        docs[id] = doc;
        
        emit DocAdded(id, no, msg.sender, hash);
    }
    
    function findDocById(uint256 _id) public returns (DocDigest memory){
        DocDigest memory doc;
        
        return doc;
    }
    
    function findDocsByRegistar(address _provider) public returns (DocDigest[] memory){
        DocDigest[] memory docs;
        
        return docs;
    }
    
    
    
    
    
    
    
    
    
}