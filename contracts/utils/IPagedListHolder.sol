// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;


interface IPagedListHolder {
    
    function getAllowedPageSizes() external view returns(uint256[] memory);
    
    function setAllowedPageSizes(uint256[] memory sizes, uint256 defaultSize) external;
    
    function setDefaultPageSize(uint256 size) external; 
    
    function getPageCount() external view returns(uint256);

}