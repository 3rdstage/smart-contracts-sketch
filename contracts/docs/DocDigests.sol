// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity ^0.7.5;

import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../../node_modules/@openzeppelin/contracts/math/Math.sol";

struct DocDigest{

    bytes hash;
    string algorithm;
    
    string title;
    string format;
    string filename;
    string url;
    // poId ?
           
    address registar;
    
    address[] stakeholders;    // make sure that there's no duplicates
}

// @TODO
// Whitelist or blacklist for registar.
// Meta or tag field for DocDigest struct
// Express or define relations between documents - amendment

contract DocDigests {
    using EnumerableSet for EnumerableSet.UintSet;
    using Math for uint256;
    
    // main storage, `doc-id::uint256` -> `doc-digest`
    mapping(uint256 => DocDigest) private docs;
    
    EnumerableSet.UintSet private ids;
    
    // index storage, `doc-provider` -> `doc-id[]`
    mapping(address => EnumerableSet.UintSet) private docsByRegistar;
    
    mapping(address => EnumerableSet.UintSet) private docsByStakeholder;

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
        
        docsByRegistar[msg.sender].add(id);
        for(uint256 i = 0; i < stakeholders.length; i++) docsByStakeholder[stakeholders[i]].add(id);

        emit DocAdded(id, no, msg.sender, hash);
    }
    
    function findDocById(uint256 _id) public view returns (DocDigest memory){

        return docs[_id];
    }
    
    function countDocsByRegistar(address _registar) public view returns (uint256){

        return docsByRegistar[_registar].length();
    }
    
    function findDocsByRegistar(address _registar, uint256 _from, uint256 _cnt) public view returns (DocDigest[] memory){
        
        require(_from >= 0, "");
        require(_cnt >= 0, "");
        
        DocDigest[] memory found;
        uint256 len = docsByRegistar[_registar].length();
        
        if(_from < len){
            for(uint256 i = 0; i < _cnt.min(len - _from); i++){
                found[i] = docs[docsByRegistar[_registar].at(_from + i)];
            }
        }

        return found;
    }
    
    function countDocsByStakeholder(address _stakeholder) public view returns (uint256){
        
        return docsByStakeholder[_stakeholder].length();
    }
    
    
    function findDocsByStakeholder(address _stakeholder, uint256 _from, uint256 _cnt) public view returns (DocDigest[] memory){
        
        require(_from >= 0, "");
        require(_cnt >= 0, "");
        
        DocDigest[] memory found;
        uint256 len = docsByStakeholder[_stakeholder].length();
        
        if(_from < len){
            for(uint256 i = 0; i < _cnt.min(len - _from); i++){
                found[i] = docs[docsByStakeholder[_stakeholder].at(_from + i)];
            }
        }
        
        return found;
    }

    
}