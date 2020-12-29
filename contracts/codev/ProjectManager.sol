// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./tokens/RegularERC20Token.sol";
import "./Commons.sol";
import "./Project.sol";
import "./Votes.sol";
import "./IRewardModel.sol";


contract ProjectManagerL is Context, AccessControl{
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.AddressSet;
    using RewardArrayLib for Reward[];
  
    RegularERC20TokenL private token;                  // token contract for reward
    
    EnumerableMap.UintToAddressMap private projects;   // projects map (id => address)
    
    mapping(address => string) private rewardModels;   // reward models map (address => name)
    
    EnumerableSet.AddressSet private rewardModelAddrs; // key-set for reward models map 
    
    VotesL private votesContract;                      // votes contract

    event ProjectCreated(uint256 indexed id, address addr, uint256 totalReward, uint8 contirbPercent, address rewardModelAddr);
    
    event RewardModelRegistered(address indexed addr, string name);
    
    event TokenCollected(address indexed from, uint256 amount);
    
    event VoteeRewarded(uint256 indexed projectId, address indexed votee, uint256 amount);
    
    event VoterRewarded(uint256 indexed projectId, address indexed voter, uint256 amount);


    /**
     * To distribute rewards, it is neccesary to grant MINTER_ROLE of the token to this project manager contract
     * outside of this contract usually at contract deploy time.
     */
    constructor(address _tknAddr) public{
        require(_tknAddr != address(0), "Token address can't be ZERO.");
        token = RegularERC20TokenL(_tknAddr);    
        
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function getTokenAddress() external view returns (address){
        return address(token);
    }

    function setVotesContact(address _addr) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");
        require(_addr != address(0), "Votes contract can't be ZERO.");
        
        votesContract = VotesL(_addr);
    }

    function createProject(uint256 _id, string memory _name, uint256 _totalReward, uint8 _contribsPerct, address _rewardModelAddr) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");
        require(!projects.contains(_id), "Duplicated project ID"); 
        require(rewardModelAddrs.contains(_rewardModelAddr), "No such reward model registered.");

        ProjectL prj = new ProjectL(_id, _name, _totalReward, _contribsPerct, _rewardModelAddr);
        projects.set(_id, address(prj));
        
        emit ProjectCreated(_id, address(prj), _totalReward, _contribsPerct, _rewardModelAddr);        
    }
    
    function getNumberOfProjects() external view returns (uint256){
        return projects.length();
    }
    
    function hasProject(uint256 _prjId) external view returns (bool){
        return projects.contains(_prjId);
    }
    
    function getProjectAddress(uint256 _prjId) external view returns (address){
        return address(_findProject(_prjId));
    }

    function _findProject(uint256 _prjId) internal view returns (ProjectL){
        require(projects.contains(_prjId), "No such project.");
        
        return ProjectL(projects.get(_prjId));
    }

    function _setProjectRewarded(uint256 _prjId) internal{
        ProjectL prj = _findProject(_prjId);
        prj.setRewarded();
    }
    
    function registerRewardModels(address[] memory _modelAddrs) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");

        uint256 l = _modelAddrs.length;
        for(uint256 i = 0; i < l; i++) _registerRewardModel(_modelAddrs[i]);
    }

    function registerRewardModel(address _modelAddr) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");

        _registerRewardModel(_modelAddr);
    } 
    
    function _registerRewardModel(address _modelAddr) internal{
        require(_modelAddr != address(0), "Reward model can't be ZERO.");
        // allow re-register
        //require(!rewardModelAddrs.contains(_modelAddr), "ProjectManager: The reward model at the specified address was registered already.");
        
        rewardModels[_modelAddr] = IRewardModelL(_modelAddr).getName();
        rewardModelAddrs.add(_modelAddr);
        emit RewardModelRegistered(_modelAddr, rewardModels[_modelAddr]);
    }
    
    function getNumberOfRewardModels() external view returns (uint256){
        return rewardModelAddrs.length();
    }
    
    function getRewardModel(uint256 _index) external view returns (address addr, string memory name){
        require(_index < rewardModelAddrs.length(), "Too large index." );
        
        (addr, name) = (rewardModelAddrs.at(_index), rewardModels[rewardModelAddrs.at(_index)]);
    }
    

    function assignProjectVoters(uint256 _prjId, address[] calldata _voters) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");

        _findProject(_prjId).assignVoters(_voters);
    }
    
    function getProjectVoters(uint256 _prjId) external view returns(address[] memory){

        return _findProject(_prjId).getVoters();
    }
    
    
    /**
     * Try to collect token (send token to me from owner) using `transferFrom` function.
     * It would fail unless the `_owner` previously approved this project manager address as much
     * allowance as `_amt`.
     * 
     * After collecting token from a voter, as much token is approved to votes contract, 
     * in case of unvote or update vote from the same voter
     */
    function collectFrom(address _owner, uint256 _amt) external{
        // collect token from voter
        token.transferFrom(_owner, address(this), _amt);
        
        // approve as much token to votes contract, in case of unvote or update vote
        token.approve(address(votesContract), _amt);
        emit TokenCollected(_owner, _amt);
    }
    
    
    function simulateRewardsArrayRetuns(uint256 _prjId) external view 
            returns(address[] memory votees, uint256[] memory voteeRewards, address[] memory voters, uint256[] memory voterRewards, uint256 remainder){
        
        (Reward[] memory vteeRwds, Reward[] memory vterRwds, uint256 rmnd) = _simulateRewards(_prjId);
        
        (votees, voteeRewards) = vteeRwds.toPrimitiveArrays();
        (voters, voterRewards) = vterRwds.toPrimitiveArrays();
        remainder = rmnd;
    }    
        
    
    function _simulateRewards(uint256 _prjId) internal view 
            returns(Reward[] memory voteeRewards, Reward[] memory voterRewards, uint256 remainder){
        ProjectL prj = _findProject(_prjId);
        
        Vote[] memory vts = votesContract.getVotesByProject(_prjId);
        Score[] memory scrs = votesContract.getScoresByProject(_prjId);
        
        require(vts.length > 0, "Project has no vote yet.");
        
        (uint256 ttl, uint8 prct) = prj.getRewardPot();
        return IRewardModelL(prj.getRewardModelAddress()).calcRewards(RewardPot(ttl, prct), vts, scrs, 16);
    }

    function distributeRewards(uint256 _prjId) public{
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");
        
        _findProject(_prjId).setRewarded();
        (Reward[] memory vteeRwds, Reward[] memory vterRwds, uint256 rmnd) = _simulateRewards(_prjId);
        
        uint256 l = vteeRwds.length;
        for(uint256 i = 0; i < l; i++){  // mint token to votees
            token.mint(vteeRwds[i].to, vteeRwds[i].amount);
            emit VoteeRewarded(_prjId, vteeRwds[i].to, vteeRwds[i].amount);
        }
        
        l = vterRwds.length;
        for(uint256 i = 0; i < l; i++){  // mint token to voters
            token.mint(vterRwds[i].to, vterRwds[i].amount);
            emit VoterRewarded(_prjId, vterRwds[i].to, vterRwds[i].amount);
        }

        token.mint(address(this), rmnd);
    }
}