// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

struct Contrib{
    address owner;  // should never be ZERO address
    string title;
    string docUrl;
    bytes32 docHash;
}

struct Vote{
    address voter;  // never be ZERO address after instantiated
    address votee;  // target of voting
    uint256 amount;
}

struct Score{
    address owner;  // score owner
    uint256 value;  // score
}

struct RewardPot{
    uint256 total;
    uint8 contribsPercent;  // (0, 100)
}

struct Reward{
    address to;
    uint256 amount;
}


library RewardArrayLib{
    
    function toPrimitiveArrays(Reward[] memory _rewards) public pure returns (address[] memory winners, uint256[] memory amounts){
        uint256 l = _rewards.length;
        winners = new address[](l);
        amounts = new uint256[](l);
        
        for(uint256 i = 0; i < l; i++){
            winners[i] = _rewards[i].to;
            amounts[i] = _rewards[i].amount;
        }
    }
}
