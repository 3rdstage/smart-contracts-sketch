// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import '../utils/IPagedListHolder.sol';

struct Offer{
    uint256 id; //offer ID
    uint256 assetId;
    address offerer;
    uint256 lowestPrice;
    uint256 closedAt;
    bool isWithdrawn;
    bool isOpen;
}

struct Bid{
    uint256 id; //bid ID
    uint256 offerId;
    address bidder;
    uint256 price;
    bool isWithdrawn;
    bool isAccepted;
}

interface ISingleOriginAuction is IPagedListHolder{

    function offer(uint256 assetId, uint256 lowestPrice, uint256 closeAt) external returns(uint256 offerId);
    
    function withdrawOffer(uint256 assetId) external;
    
    function bid(uint256 assetId, uint256 price) external returns(uint256 bidId);
    
    function withdrawBid(uint256 assetId) external;
    
    function getAllOpenOffersCount() external view returns(uint256 count);

    function findOpenOffersInPage(uint256 page) external view returns(Offer[] memory);

    function findOpenOffersInPage(uint256 page, uint256 pageSize) external view returns(Offer[] memory);
    
    function findOffers(uint256[] memory offerIds) external view returns(Offer[] memory);
    
    function findOffersByOfferer(address offerer) external view returns(uint256[] memory offerIds);
    
    function findOpenOffersByOfferer(address offerer) external view returns(uint256[] memory offerIds);
    
    function findBids(uint256[] memory bidIds) external view returns(Bid[] memory);
    
    function findBidsByOffer(uint256 offerId) external view returns(uint256[] memory bidIds);
    
    
    

}