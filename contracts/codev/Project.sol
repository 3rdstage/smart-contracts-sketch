// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./Commons.sol";
import "./IRewardModel.sol";


contract ProjectL is Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 private id;

    string private name;

    RewardPot rewardPot;
    
    IRewardModelL private rewardModel;

    EnumerableSet.AddressSet private voters;

    bool private rewarded = false;   // whether or not rewards are distributed to contributors and voters
    
    event RewardPotUpdated(uint256 indexed projectId, uint256 totalReward, uint8 contribsPercent);
    
    event RewardModelDesignated(uint256 indexed projectId, address modelAddr);
    
    event VoterAssigned(uint256 indexed projectId, address voter);
    
    event VoterUnassigned(uint256 indexed projectId, address voter);
    
    event RewardDistributed(uint256 indexed projectId);
    
    constructor(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) public{
        id = _id;
        name = _name;
        
        _setRewardPot(_totalReward, _contribsPerct);
        rewardModel = IRewardModelL(_rewardModelAddr); // @TODO
    }
  
    function getId() external view returns (uint256){
        return id;
    }
    
    function getName() external view returns (string memory){
        return name;
    }

    function _setRewardPot(uint256 _total, uint8 _contribsPerct) internal{
        require(_total > 0, "Project: Require positie total reward.");
        require(_contribsPerct > 0 && _contribsPerct < 100, "Project: Percentage range : (0, 100).");
        require(!rewarded, "Project: Already rewarded.");
        
        rewardPot = RewardPot(_total, _contribsPerct); 
        emit RewardPotUpdated(id, _total, _contribsPerct);
    }
    
    function setRewardPot(uint256 _total, uint8 _contribsPerct) external onlyOwner{
        _setRewardPot(_total, _contribsPerct);
    }
    
    function getRewardPot() external view returns (uint256 total, uint8 contribsPerct){
        return (rewardPot.total, rewardPot.contribsPercent);
    }
    
    function setRewardModel(address _addr) external onlyOwner{
        require(_addr != address(0), "Project: Model address can't be ZERO.");
        require(!rewarded, "Project: Already rewarded.");
        
        rewardModel = IRewardModelL(_addr);
        emit RewardModelDesignated(id, _addr);
    }
    
    function hasRewardModel() external view returns (bool){
        return (address(rewardModel) != address(0));
    }
    
    function getRewardModelAddress() external view returns (address){
        return address(rewardModel);
    }

    function assignVoters(address[] calldata _voters) external onlyOwner{
        require(!rewarded, "Project: Already rewarded.");

        uint256 l = _voters.length;
        for(uint i = 0; i < l; i++) require(_voters[i] != address(0), "Project: Voter address can't be ZERO.");
        
        l = voters.length();
        address vter;
        for(uint256 i = l; i > 0; i--){
            vter = voters.at(i - 1);
            voters.remove(vter);
            emit VoterUnassigned(id, vter);
        }

        l = _voters.length;
        for(uint i = 0; i < l; i++){
            vter = _voters[i];
            voters.add(_voters[i]);
            emit VoterAssigned(id, _voters[i]);
        } 
    }
    
    // will retrun empty array at initial state
    function getVoters() external view returns (address[] memory){
        uint256 l = voters.length();
        address[] memory _voters = new address[](l);
        
        for(uint256 i = 0; i < l; i++){
            _voters[i] = voters.at(i);
        }
        return _voters;
    }
    
    function hasVoter(address _voter) external view returns (bool){
        return voters.contains(_voter);
    }

    function setRewarded() external onlyOwner{
        require(!rewarded, "Project: Already rewarded.");
        
        rewarded = true;
        emit RewardDistributed(id);
    }

    function isRewarded() external view returns (bool){
        return rewarded;
    }    

}
