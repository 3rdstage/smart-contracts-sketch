// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/Math.sol";

abstract contract BidderRestricted{
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;

    //@TODO Apply `IPagedListHolder`

    event InvitedBidderAdded(address indexed bidder);
    event InvitedBidderRemoved(address indexed bidder);
    event InvitedBiddersCleared();

    EnumerableSet.AddressSet private _invitedBidders;

    function getNumberOfInvitedBidders() public view returns(uint256){
        return _invitedBidders.length();
    }

    function getInvitedBidders() public view returns(address[] memory){
        address[] memory addrs;

        uint256 n = _invitedBidders.length();
        for(uint256 i = 0; i < n; i++){
            addrs[i] = _invitedBidders.at(i);
        }

        return addrs;
    }

    function addInvitedBidders(address[] memory addrs) public{

        uint256 n = addrs.length;
        for(uint256 i = 0; i < n; i++){
            if(_invitedBidders.contains(addrs[i])){
                _invitedBidders.add(addrs[i]);
                emit InvitedBidderAdded(addrs[i]);
            }
        }
    }

    function removeInvitedBidders(address[] memory addrs) public{

        uint256 n = addrs.length;
        for(uint256 i = 0; i < n; i++){
            if(_invitedBidders.contains(addrs[i])){
                _invitedBidders.remove(addrs[i]);
                emit InvitedBidderRemoved(addrs[i]);
            }
        }
    }

    function clearInvtedBidders() public{

        //@TODO Needs test to confirm correct behavior
        delete _invitedBidders;
        emit InvitedBiddersCleared();
    }








}