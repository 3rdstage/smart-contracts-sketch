// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./tokens/RegularERC20Token.sol";
import "./Commons.sol";
import "./ProjectManager.sol";
import "./Project.sol";
import "./Contributions.sol";


contract VotesL is Context, AccessControl{
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    ProjectManagerL private projectManager;   // project manager contract
    
    ContributionsL private contribsContract;  // contributions contract
    
    RegularERC20TokenL private token;         // token contract

     // votes by project and voter
    mapping(uint256 => mapping(address => Vote)) private votes;     // (project, voter) => (votee, amount)
    
    mapping(uint256 => EnumerableSet.AddressSet) private voters;    // project => voter, key-set of votes, for safe access or iteration
    
    mapping(uint256 => mapping(address => uint256)) private scores; // (project, votee) => score
    
    mapping(uint256 => EnumerableSet.AddressSet) private votees;    // project => votee, key-set of scores, for safe access or iteration

    event Voted(uint256 indexed projectId, address indexed voter, address indexed votee, uint256 amt, uint256 score);
    
    event NoPreviousVote(uint256 indexed projectId, address indexed voter);
    
    event Unvoted(uint256 indexed projectId, address indexed voter);
    
    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");
        _;
    }
    
    constructor(address _prjMgr, address _contribsCtr) public{
        require(_prjMgr != address(0), "Votes: Project manager can't be ZERO.");
        require(_contribsCtr != address(0), "Votes: Contribs contract can't be ZERO.");
        
        projectManager = ProjectManagerL(_prjMgr);
        contribsContract = ContributionsL(_contribsCtr);
        token = RegularERC20TokenL(projectManager.getTokenAddress());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());        
    }
    
    function vote(uint256 _prjId, address _votee, uint256 _amt) public{
        require(_votee != address(0), "Votes: Can't vote on ZERO address.");
        require(_amt > 0, "Votes: Require positive voting amount.");

        // validation : project existence and state, contribution existence, voting right
        address vtr = _msgSender(); // voter
        ProjectL prj = ProjectL(projectManager.getProjectAddress(_prjId));
        require(!prj.isRewarded(), "Votes: Rewarded already.");
        require(prj.hasVoter(vtr), "Votes: No voter for the project.");
        require(contribsContract.hasContribution(_prjId, _votee), "Votes: No votee yet");
        
        // check allowance
        require(token.allowance(vtr, address(projectManager)) >= _amt, "Votes: Token allowance shortage");
        
        bool unvoted = false;
        uint256 amt0 = 0;
        // unvote first if necessary
        if(votes[_prjId][vtr].voter != address(0)){
          amt0 = votes[_prjId][vtr].amount;
          _unvote(_prjId, vtr);
          unvoted = true;
        } 

        uint256 scr1 = scores[_prjId][_votee];    // votee's current score
        scores[_prjId][_votee] = scr1.add(_amt);  // update votee's score
        votees[_prjId].add(_votee);               // update `scores`' keys

        // update `votes` and `votes`' keys
        votes[_prjId][vtr] = Vote(vtr, _votee, _amt);
        voters[_prjId].add(vtr);
        
        emit Voted(_prjId, vtr, _votee, _amt, scores[_prjId][_votee]);
        // collect voting amount first
        if(unvoted) token.transferFrom(address(projectManager), vtr, amt0);  // refund previous voting amount
        projectManager.collectFrom(vtr, _amt);

    }
    
    
    // @TODO Not complete - remove or finish this.
    function unvote(uint256 _prjId) public{
        require(projectManager.hasProject(_prjId), "Votes: No such project.");
        require(!(ProjectL(projectManager.getProjectAddress(_prjId)).isRewarded()), "Votes: Rewarded already.");
        
        _unvote(_prjId, _msgSender());
        token.transferFrom(address(projectManager), _msgSender(), votes[_prjId][_msgSender()].amount);  // refund previous voting amount
    }
    
    function _unvote(uint256 _prjId, address _voter) internal{

        Vote memory vt0 = votes[_prjId][_voter];
        if(vt0.voter != address(0)){                    // has pervious vote
            uint256 amt0 = vt0.amount;                  // previous vote amount
            uint256 scr0 = scores[_prjId][vt0.votee];   // previous votee's current score
            scores[_prjId][vt0.votee] = scr0.sub(amt0); // update previous votee's score
            
            delete votes[_prjId][_voter];             // remove prev. vote from votes
            voters[_prjId].remove(_voter);            // update votes' key-set
            
            emit Unvoted(_prjId, _voter);
        }else{
            emit NoPreviousVote(_prjId, _voter);
        }
    }

    function getVote(uint256 _prjId, address _voter) public view returns (address, uint256) {
        
        return (votes[_prjId][_voter].votee, votes[_prjId][_voter].amount);
    }
    
    function getVotesByProject(uint256 _prjId) public view returns (Vote[] memory){ 
    
        uint256 l = voters[_prjId].length(); 
        Vote[] memory vts = new Vote[](l);  // what if `l` is ZERO
        
        for(uint256 i = 0; i < l; i++) vts[i] = votes[_prjId][voters[_prjId].at(i)];
        return vts;
    }
    
    function getScoresByProject(uint256 _prjId) public view returns (Score[] memory){
        
        uint256 l = votees[_prjId].length();
        Score[] memory scrs = new Score[](l); // what if `l` is ZERO
        
        for(uint256 i = 0; i < l; i++){
            address vtee = votees[_prjId].at(i);
            scrs[i] = Score(vtee, scores[_prjId][vtee]);
        }
        return scrs;
    }
}

    