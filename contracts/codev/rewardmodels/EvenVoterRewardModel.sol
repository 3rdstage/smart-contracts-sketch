// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./ProportionalRewardModel.sol";


contract EvenVoterRewardModelL is ProportionalRewardModelL(1, 1){ 
    using SafeMath for uint256;

    string private constant name = "Proportional rewards for votees and even rewards for voters";

    function getName() external view virtual override returns (string memory){
        return name;
    }
    
    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores, uint256 _floorAt) 
        external view override virtual returns (Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
        
        require(_rewardPot.total > 0, "EvenVoterRewardModel: The specified total reward is ZERO.");
        require(_rewardPot.contribsPercent > 0 && _rewardPot.contribsPercent < 100, "EvenVoterRewardModel: The percentage for contributors should be between 0 and 100 exclusively.");
        require(_scores.length > 0, "EvenVoterRewardModel: The specified votee scores are empty.");
        require(_votes.length > 0, "EvenVoterRewardModel: The speified votes are empty.");
        require(_floorAt <= FLOOR_AT_MAX, "ProportionalRewardModel: Too much high floor position - It should be less than or equal to 18");

        // calculate votees' rewards first based on scores
        uint256 vteeTotal = _rewardPot.total.mul(_rewardPot.contribsPercent).div(100);  // total reward amount for votees
        voteeRewards = _calcVoteeRewards(vteeTotal, _scores);

        // calc voters' rewards
        voterRewards = _calcVoterRewards(_rewardPot.total.sub(vteeTotal), _votes);
        
        if(_floorAt > 0){
            _floor(voteeRewards, _floorAt);
            _floor(voterRewards, _floorAt);
        }
        
        // calc remainder
        remainder = _calcRemainder(_rewardPot.total, voteeRewards, voterRewards);
    }
    
    function _calcVoterRewards(uint256 _totalAmt, Vote[] calldata _votes) internal pure virtual returns(Reward[] memory rewards){

        uint256 m = _votes.length;
        rewards = new Reward[](m);     // output parameter
        for(uint256 i = 0; i < m; i++){
            rewards[i] = Reward(_votes[i].voter, _totalAmt.div(m));     
        }        
    }

}