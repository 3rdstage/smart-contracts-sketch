// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
//pragma experimental ABIEncoderV2;

import './IPagedListHolder.sol';

import "@openzeppelin/contracts/utils/EnumerableSet.sol";

abstract contract PagedListHolder is IPagedListHolder {
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _defaultSize;
    EnumerableSet.UintSet private _sizes;

    constructor(uint256 defaultPageSize) internal{
        _defaultSize = defaultPageSize;
    }

    function getAllowedPageSizes() public view override returns(uint256[] memory){
        uint256[] memory sizes;
        uint256 n = _sizes.length();

        for(uint256 i = 0; i < n; i++){
            sizes[i] = _sizes.at(i);
        }

        return sizes;
    }

    function setAllowedPageSizes(uint256[] memory sizes, uint256 defaultSize) public override{

        require(defaultSize > 0, "Page size cann't be zero.");

        delete _sizes;
        uint256 n = sizes.length;
        for(uint256 i = 0; i < n; i++){
            require(sizes[i] > 0, "Page size cann't be zero.");
            _sizes.add(sizes[i]);
        }

        _sizes.add(defaultSize);
        _defaultSize = defaultSize;
    }

    function setDefaultPageSize(uint256 size) public override{
        require(size > 0, "Page size cann't be zero.");

        _sizes.remove(_defaultSize);
        _sizes.add(size);
        _defaultSize = size;
    }

    function getDefaultPageSize() public view override returns(uint256){
        return _defaultSize;
    }

    function isAllowedPageSize(uint256 size) public view override returns(bool){

        return _sizes.contains(size);
    }

}