// SPDX-License-Identifier: UNLICENSED
pragma experimental ABIEncoderV2;
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "./DocDigests.sol";

struct DocSigning{

    uint256 docId;

    address signer;

    uint256 at; //
}

contract DocSignings {

    DocDigests private docsContract;

    mapping(uint256 => DocSigning[]) private signingsByDoc;


    constructor(address _docsCntrAddr){
        require(_docsCntrAddr != address(0), "Contract address can'be ZERO");

        docsContract = DocDigests(_docsCntrAddr);

    }

    function sign(uint256 _docId) public{
        DocDigest memory doc = docsContract.findDocById(_docId);

        if(doc.hash.length == 0){ }

        uint256 signs = 0;
        address[] memory holders = doc.stakeholders;
    }

    function hasSigned(uint256 _docId) public view returns (bool){

        return false;
    }

    function hasSigned(uint256 _docId, address _signer) public view returns(bool){

        return false;
    }

    function hasSiginedByAll(uint256 _docId) public view returns(bool){

    }


    function findSigningsOfMine() public view returns(DocSigning[] memory){

    }

    function findSigningByDoc(uint256 _docId) public view returns(DocSigning[] memory){

        DocSigning[] memory signings = signingsByDoc[_docId];

        return signings;
    }

}