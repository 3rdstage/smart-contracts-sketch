
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../IRewardModel.sol";

abstract contract AbstractRewardModelL is IRewardModelL{
    using SafeMath for uint256;
    
    uint256 public constant FLOOR_AT_MAX = 18;

    function _calcRemainder(uint256 _totalRwd, Reward[] memory _vteeRwds, Reward[] memory _vterRwds) 
        internal pure returns (uint256){
        
        uint256 rmder = _totalRwd;
        uint256 l = _vteeRwds.length;   // votees number
        for(uint256 i = 0; i < l; i++) rmder = rmder.sub(_vteeRwds[i].amount);

        l = _vterRwds.length;            // voters number
        for(uint256 i = 0; i < l; i++) rmder = rmder.sub(_vterRwds[i].amount);

        return rmder;
    }
    
    function _floor(Reward[] memory _rwds, uint256 _at) internal pure{
        require(_at <= FLOOR_AT_MAX, "AbstractRewardModel: Too much high floor position - It should be less than or equal to 18");

        uint256 l = _rwds.length;
        for(uint256 i = 0; i < l; i++) _rwds[i].amount = _rwds[i].amount.div(10**_at).mul(10**_at);
    }


}