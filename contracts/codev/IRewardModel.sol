// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Commons.sol";

interface IRewardModelL{

    function getName() external view returns (string memory);

    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores, uint256 _floorAt) 
        external view returns (Reward[] memory voteeRewards, Reward[] calldata voterRewards, uint256 remainder);

}