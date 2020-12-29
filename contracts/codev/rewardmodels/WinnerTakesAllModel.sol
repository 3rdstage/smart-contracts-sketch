// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./EvenVoterRewardModel.sol";

contract WinnerTakesAllModelL is EvenVoterRewardModelL{
     using SafeMath for uint256;
   
    string private constant name = "Winner-Takes-All reward model";
    
    function getName() external view virtual override returns (string memory){
        return name;
    }
    
    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores, uint256 _floorAt) 
        external view override virtual returns (Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
        
        require(_rewardPot.total > 0, "WinnerTakesAllModel: The specified total reward is ZERO.");
        require(_rewardPot.contribsPercent > 0 && _rewardPot.contribsPercent < 100, "WinnerTakesAllModel: The percentage for contributors should be between 0 and 100 exclusively.");
        require(_scores.length > 0, "WinnerTakesAllModel: The specified votee scores are empty.");
        require(_votes.length > 0, "WinnerTakesAllModel: The speified votes are empty.");
        require(_floorAt <= FLOOR_AT_MAX, "WinnerTakesAllModel: Too much high floor position - It should be less than or equal to 18");

        // calculate votees' rewards first based on scores
        uint256 vteeTotal = _rewardPot.total.mul(_rewardPot.contribsPercent).div(100); // total reward amount for votees
 
        // select top ranker(s) 
        address[] memory topVtees = new address[](_scores.length);  // top scored votees - tie is possiblee
        {                                        // block to avoid 'stack too deep'
            uint256 l = _scores.length;       
            uint256 topScr = 0;                  // top score
            uint256 curScr;                      // current score under iteration
            uint256 cnt = 0;                     // tie top ranker count
            for(uint256 i = 0; i < l; i++){
                curScr = _scores[i].value;
                if(curScr > topScr){             // new top ranker
                    topScr = curScr;
                    topVtees[0] = _scores[i].owner;
                    cnt = 1;
                }else if(curScr == topScr){      // tie top ranker
                    topVtees[cnt++] = _scores[i].owner;
                }
            }

            // leave only real top ranker(s)
            address[] memory topVtees2 = new address[](cnt);
            for(uint256 i = 0; i < cnt; i++) topVtees2[i] = topVtees[i];
            topVtees = topVtees2;
            assert(topVtees.length > 0);         // should be guaranteed internally
        }

        // calc. votees' rewards
        voteeRewards = _calcVoteeRewards(vteeTotal, _scores, topVtees);

        // calc voters' rewards
        voterRewards = _calcVoterRewards(_rewardPot.total.sub(vteeTotal), _votes);
        
        if(_floorAt > 0){
            _floor(voteeRewards, _floorAt);
            _floor(voterRewards, _floorAt);
        }
        
        // calc remainder
        remainder = _calcRemainder(_rewardPot.total, voteeRewards, voterRewards);
    }
    
    function _calcVoteeRewards(uint256 _totalAmt, Score[] calldata _scores, address[] memory _topVotees) 
            internal pure virtual returns(Reward[] memory rewards){
        
        uint256 l = _scores.length;
        uint256 m = _topVotees.length;
        
        rewards = new Reward[](l);
        for(uint256 i = 0; i < l; i++){
            rewards[i].to = _scores[i].owner;
            for(uint256 j = 0; j < m; j++){
                if(_scores[i].owner == _topVotees[j]){
                    rewards[i].amount = _totalAmt.div(m);
                    break;
                }
            }
        }
    }
    
    
    
    
}