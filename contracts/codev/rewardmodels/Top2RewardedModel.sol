// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./AbstractRewardModel.sol";


// Not yet implemented. Remove 'abstract' when implemented. 
abstract contract Top2RewardedModelL is AbstractRewardModelL{
    
    string private constant name = "Top 2 voters are rewarded model";

    function getName() external view virtual override returns (string memory){
        return name;
    }


}