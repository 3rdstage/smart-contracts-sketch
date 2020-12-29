// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "./AbstractRewardModel.sol";

contract ProportionalRewardModelL is AbstractRewardModelL{
    using SafeMath for uint256;

    string private constant name = "Proportionally rewarded model";
    
    uint256 private immutable voterHighPortion;
    
    uint256 private immutable voterBasePortion;
    
    function getName() external view virtual override returns (string memory){
        return name;
    }
    
    constructor(uint8 _vtrHighPort, uint8 _vtrBasePort) public {
        require(_vtrHighPort >= _vtrBasePort, "ProportionalRewardModel: High portion should be equal or greater than base portion");
        
        voterHighPortion = _vtrHighPort;
        voterBasePortion = _vtrBasePort;
    }

    function calcRewards(RewardPot calldata _rewardPot, Vote[] calldata _votes, Score[] calldata _scores, uint256 _floorAt) 
        external view override virtual returns (Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){

        require(_rewardPot.total > 0, "ProportionalRewardModel: The specified total reward is ZERO.");
        require(_rewardPot.contribsPercent > 0 && _rewardPot.contribsPercent < 100, "ProportionalRewardModel: The percentage for contributors should be between 0 and 100 exclusively.");
        require(_votes.length > 0, "ProportionalRewardModel: The speified votes are empty.");
        require(_scores.length > 0, "ProportionalRewardModel: The specified votee scores are empty.");
        require(_floorAt <= FLOOR_AT_MAX, "ProportionalRewardModel: Too much high floor position - It should be less than or equal to 18");

        // calculate votees' rewards first based on scores
        uint256 vteeTotal = _rewardPot.total.mul(_rewardPot.contribsPercent).div(100);  // total reward amount for votees
        voteeRewards = _calcVoteeRewards(vteeTotal, _scores);

        // select top ranker(s) 
        address[] memory topVtees = new address[](_scores.length);  // top scored votees - tie is possiblee
        {                                        // block to avoid 'stack too deep'
            uint256 l = _scores.length;          // number of votees
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

        // calc voters' rewards
        //Vote[] memory vts = _votes;              // local copy to avoid 'stack too deep'
        voterRewards = _calcVoterRewards(_rewardPot.total.sub(vteeTotal), topVtees, _votes);
        
        if(_floorAt > 0){
            _floor(voteeRewards, _floorAt);
            _floor(voterRewards, _floorAt);
        }
        
        // calc remainder
        remainder = _calcRemainder(_rewardPot.total, voteeRewards, voterRewards);
    }
    
    function _calcVoteeRewards(uint256 _totalAmt, Score[] calldata _scores) internal pure virtual returns(Reward[] memory rewards){
        
        uint256 l = _scores.length;
        rewards = new Reward[](l);     // output parameter
        uint256 scrSum = 0;            // sum of votee scores
        for(uint256 i = 0; i < l; i++) scrSum = scrSum.add(_scores[i].value);
        for(uint256 i = 0; i < l; i++){
            rewards[i] = Reward(_scores[i].owner, _totalAmt.mul(_scores[i].value).div(scrSum));     
        }
    }

    function _calcVoterRewards(uint256 _totalAmt, address[] memory _topVotees, Vote[] calldata _votes) 
        internal view virtual returns(Reward[] memory rewards){   // `view` visibility for derived contracts
        
        require(_topVotees.length > 0, "ProportionalRewardModel: Top ranked votees should be at least one.");
        
        // determine voters' portions - voted to top ranker(s) : high portion, otherwise : base portion
        uint256 m = _votes.length;                     // number of voters
        uint256[] memory vtrPrts = new uint256[](m);   // voter portions - indexed by the position in `_votes` param
        uint256 totalWghts = 0;                        // sum of voters' weights (portion x vote amount)
        {                                              // block to avoid 'stack too deep'
            uint256 k = _topVotees.length;    
            address curVtee;                           // current votee address under iteration
            for(uint256 i = 0; i < m; i++){
                vtrPrts[i] = voterBasePortion;         // set base portion first
                curVtee = _votes[i].votee;
                for(uint256 j = 0; j < k; j++){        // iterate over top rankers (top votees)
                    if(_topVotees[j] == curVtee){      // if the current vote hit the one of the top rankers
                        vtrPrts[i] = voterHighPortion; // update voter's portion to high portion
                        break;
                    }
                }
                totalWghts = totalWghts.add(vtrPrts[i].mul(_votes[i].amount));
            }
        }

        rewards = new Reward[](m);
        uint256 amt;                // reward amount for each voter under iteration
        // fianlly calculate rewards for all voters
        for(uint256 i = 0; i < m; i++){
            amt = _totalAmt.mul(_votes[i].amount).mul(vtrPrts[i]).div(totalWghts);
            rewards[i] = Reward(_votes[i].voter, amt);
        }
    }
    


}