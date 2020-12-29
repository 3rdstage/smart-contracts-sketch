// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "../../node_modules/@openzeppelin/contracts/GSN/Context.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../../node_modules/@openzeppelin/contracts/utils/EnumerableMap.sol";
import "./Commons.sol";
import "./ProjectManager.sol";


contract ContributionsL is Context, AccessControl{

    ProjectManagerL private projectManager;
    
    mapping(uint256 => mapping(address => Contrib)) private contribs;  // contributions by project
    
    mapping(uint256 => address[]) private contributors; // contributors by project, index for `contribs`

    event ContributionAdded(uint256 indexed projectId, address indexed contributior);
    
    event ContributionUpdated(uint256 indexed projectId, address indexed contributior);

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Only admin.");
        _;
    }
    
    constructor(address _prjMgr) public{
        require(_prjMgr != address(0), "Contribs: Project manager can't be ZERO.");
        
        projectManager = ProjectManagerL(_prjMgr);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    
    function addOrUpdateContribution(uint256 _prjId, address _contributior, string memory _title) external onlyAdmin{
        require(_contributior != address(0), "Contribs: Contributor can't be ZERO.");
        require(!ProjectL(projectManager.getProjectAddress(_prjId)).isRewarded(), "Contribs: Already rewarded.");
        
        bool exists = true;
        if(contribs[_prjId][_contributior].owner == address(0)) exists = false;
        
        contribs[_prjId][_contributior] = Contrib(_contributior, _title, "", 0);
        if(exists) emit ContributionUpdated(_prjId, _contributior);
        else{
            contributors[_prjId].push(_contributior);
            emit ContributionAdded(_prjId, _contributior); 
        }
    }
    
    function getContributorsByProject(uint256 _prjId) external view returns (address[] memory){
        require(projectManager.hasProject(_prjId), "Contribs: No such project.");
        
        return contributors[_prjId];        
    }
    
    function getContribution(uint256 _prjId, address _contributor) external view returns (string memory, string memory, bytes32){
        require(projectManager.hasProject(_prjId), "Contribs: No such project.");
        
        Contrib memory cntrb = contribs[_prjId][_contributor];
        require(cntrb.owner != address(0), "Contribs: No such contribution.");
        
        return (cntrb.title, cntrb.docUrl, cntrb.docHash);
    }
    
    function hasContribution(uint256 _prjId, address _contributor) external view returns (bool){
        if(!projectManager.hasProject(_prjId)) return false;
        
        if(contribs[_prjId][_contributor].owner == address(0)) return false;
        return true;
    }

}