// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import './ISingleOriginAuction.sol';
import '../utils/PagedListHolder.sol';

contract SingleOriginAuction is ISingleOriginAuction, PagedListHolder(10){
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Math for uint256;

    address private _assetContract;

    address private _tokenContract;  // ERC20 token contract for payment


    Counters.Counter private _offerIdSeq;  // sequence for offer ID

    mapping(uint256 => Offer) private _offers;  // all offers (offer ID => offer)

    EnumerableSet.UintSet private _openAssetIds;  // index : asset IDs for open offers

    mapping(uint256 => uint256) private _openOfferByAsset;  // index : asset ID => offer ID : for open offer


    Counters.Counter private _bidIdSeq;  // sequence for bid ID

    mapping(uint256 => Bid) private _bids;  // all bids (bid ID => bids)

    mapping(uint256 => EnumerableSet.UintSet) private _bidsByOffer;  // index : offer ID => bid IDs


    constructor(address assetContr) public{
        require(assetContr != address(0), "Asset contract address cann't be Zero address.");

        //@TODO How to check EIP-721 compliance for the specified asset contract
        _assetContract = assetContr;
    }

    function getAssetContractAddress() external override returns(address){
        return _assetContract;
    }

    function offer(uint256 assetId, uint256 lowestPrice, uint256 closeAt) external override returns(uint256){

        address offerer = msg.sender;
        require(offerer != address(0), "Offerer addres cann't be Zero address.");

        // @TODO Is it safe to downcast address to interface IERC721
        require(IERC721(_assetContract).ownerOf(assetId) == offerer, "The offer should be from the owner of the offered asset.");
        require(!_openAssetIds.contains(assetId), "The offered asset has already open offer. Multiple offer is not allowed for an asset.");

        // @TODO requirement for `closeAt`

        _offerIdSeq.increment();
        uint256 id = _offerIdSeq.current();
        _offers[id] = Offer(id, assetId, offerer, lowestPrice, closeAt, false, true);
        _openAssetIds.add(assetId);
        _openOfferByAsset[assetId] = id;

        emit OfferMade(id, offerer, assetId, lowestPrice, closeAt);
        return id;
    }

    function withdrawOffer(uint256 assetId) external override{

        require(IERC721(_assetContract).ownerOf(assetId) == msg.sender, "The withdrawer should be from the owner of the offered asset.");
        require(_openAssetIds.contains(assetId), "There's no open offer to withdraw.");

        uint256 id = _openOfferByAsset[assetId];
        _offers[id].isWithdrawn = true;
        _offers[id].isOpen = false;
        _openAssetIds.remove(assetId);

    }

    function bid(uint256 assetId, uint256 price) public override returns(uint256){

        require(_openAssetIds.contains(assetId), "There's no open offer for the specified asset");

        uint256 offerId = _openOfferByAsset[assetId];  // offer ID
        require(_offers[offerId].lowestPrice <= price, "The price is shorter than the lower price limit.");

        //@TODO Check the balance

        uint256 n = _bidsByOffer[offerId].length();
        for(uint256 i = 0; i < n; i++){
            Bid memory bd = _bids[_bidsByOffer[offerId].at(i)];
            require(bd.bidder != msg.sender || !bd.isWithdrawn, "The sender has a bid for the asset.");
        }

        _bidIdSeq.increment();
        uint256 bidId = _bidIdSeq.current();
        _bids[bidId] = Bid(bidId, offerId, msg.sender, price, false, false);
        _bidsByOffer[offerId].add(bidId);

        //@TODO Escrow the price from the bidder's ERC20 account

        return bidId;
    }

    function withdrawBid(uint256 assetId) public override{

        require(_openAssetIds.contains(assetId), "There's no open offer for the specified asset.");

        uint256 offerId = _openOfferByAsset[assetId];  // offer ID

        bool found = false;
        uint256 n = _bidsByOffer[offerId].length();
        for(uint256 i = 0; i < n; i++){
            Bid memory bd = _bids[_bidsByOffer[offerId].at(i)];
            if(bd.bidder == msg.sender && !bd.isWithdrawn){
                bd.isWithdrawn = true;
                found = true;
                break;
            }
        }

        require(found, "There's no valid bid to withdraw");
    }

    function getAllOpenOffersCount() public view override returns(uint256 count){

        count = _openAssetIds.length();
    }

    function findOpenOffersInPage(uint256 page) external view override returns(Offer[] memory offers){
        uint256 start = getDefaultPageSize().mul(page);

        require(start < _openAssetIds.length(), "Too large page");
        uint256 end = _openAssetIds.length().min(start + getDefaultPageSize());

        //@TODO Check the ordering of EnumerableSet.UintSet
        for(uint256 i = start; i < end; i++){
            offers[i - start] = _offers[_openOfferByAsset[_openAssetIds.at(i)]];
        }
    }

    function findOpenOffersInPage(uint256 page, uint256 pageSize) external view override returns(Offer[] memory offers){
        //@TODO

    }

    function findOffer(uint256 offerId) external view override returns(Offer memory){
        return _offers[offerId];
    }

    function findOffers(uint256[] memory offerIds) external view override returns(Offer[] memory offers){
        //@TODO
    }

    function findOffersByOfferer(address offerer) external view override returns(uint256[] memory offerIds){
        //@TODO
    }

    function findOpenOffersByOfferer(address offerer) external view override returns(uint256[] memory offerIds){
        //@TODO
    }

    function findBids(uint256[] memory bidIds) external view override returns(Bid[] memory){
        //@TODO
    }

    function findBidsByOffer(uint256 offerId) external view override returns(uint256[] memory bidIds){
        //@TODO
    }

}