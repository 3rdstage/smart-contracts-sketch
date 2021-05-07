// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import '../utils/IPagedListHolder.sol';

struct Offer{
    uint256 assetId;
    address seller;
    uint256 lowerPrice;
    uint256 closedAt;
    bool isWithdrawn;
    bool isOpen;
}

interface ISingleOriginAuction is IPagedListHolder{

    function offer(uint256 assetId, uint256 lowestPrice, uint256 closedAt) external;
    
    function withdrawOffer(uint256 assetId) external;
    
    function bid(uint256 assetId, uint256 price) external;
    
    function withdrawBid(uint256 assetId) external;
    
    function getAllOpenOffersCount() external view returns(uint256);

    function getOpenOffers(uint256 page) external view returns(Offer[] memory);

    function getOpenOffers(uint256 page, uint256 pageSize) external view returns(Offer[] memory);

}