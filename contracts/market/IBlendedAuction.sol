// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import '../utils/IPagedListHolder.sol';

struct Offer{
    address tokenContract;
    uint256 assetId;
    address seller;
    uint256 lowestPrice;
    uint256 closedAt;
    bool isWithdrawn;
    bool isOpen;
}

interface IBlendedAuction is IPagedListHolder{

    function offer(address token, uint256 assetId, uint256 lowestPrice, uint256 closedAt) external;
    
    function withdrawOffer(address token, uint256 assetId) external;
    
    function bid(address token, uint256 assetId, uint256 price) external;
    
    function withdrawBid(address token, uint256 assetId) external;

    function getAllOpenOffersCount() external view returns(uint256);

    function getOpenOffers(uint256 page) external view returns(Offer[] memory);
    
    function getOpenOffers(uint256 page, uint256 pageSize) external view returns(Offer[] memory);

}