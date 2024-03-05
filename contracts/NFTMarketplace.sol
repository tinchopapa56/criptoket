//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIDs;
    Counters.Counter private _itemsSold;

    uint256 public listingPrice = 0.025 ether; //Matic

    address payable owner;

    mapping(uint256 => MarketItem) private idToMarketItem;

    struct MarketItem {
        uint256 tokenID;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event MarketItem_Created(
        uint256 indexed ID,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // event Sold_MarketItem (uint256 indexed ID, address seller, address owner, uint256 price, bool sold);
    // event Bought_MarketItem (uint256 indexed ID, address seller, address owner, uint256 price, bool sold);

    constructor() ERC721("Cryptoket_Marketplace", "CKT") {
        owner = payable(msg.sender);
    }

    function updateListingPrice(uint _listingPrice) public payable {
        require(
            msg.sender == owner,
            "only marketplace owner can upate the listing price"
        );

        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //tokenURI : Unique Resource Identifier
    function createToken(
        string memory tokenURI,
        uint256 price
    ) public payable returns (uint) {
        _tokenIDs.increment();

        uint256 newTokenId = _tokenIDs.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);
    }

    function createMarketItem(uint256 _tokenID, uint256 _price) private {
        require(_price > 0, "Price must be at lesat 1");
        require(msg.value == listingPrice, "Price must be to listing price");

        idToMarketItem[_tokenID] = MarketItem(
            _tokenID,
            payable(msg.sender),
            payable(address(this)),
            _price,
            false
        );

        //Trasnfer ownership of nft , user => contract
        _transfer(msg.sender, address(this), _tokenID);

        emit MarketItem_Created(
            _tokenID,
            msg.sender,
            address(this),
            _price,
            false
        );
    }

    function resellToken(uint256 tokenID, uint256 price) public payable {
        bool isOwner = idToMarketItem[tokenID].owner == msg.sender;
        require(isOwner, "only owner can perform this operation");
        require(msg.value == listingPrice, "Price must be to listing price");

        idToMarketItem[tokenID].sold = false;
        idToMarketItem[tokenID].price = price;
        idToMarketItem[tokenID].seller = payable(msg.sender);
        idToMarketItem[tokenID].owner = payable(address(this));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenID);
    }

    function createMarketSell(uint256 tokenID) public payable {
        uint price = idToMarketItem[tokenID].price;

        require(
            msg.value == price,
            "Please submit the asked full price to make the buy"
        );

        idToMarketItem[tokenID].owner = payable(msg.sender);
        idToMarketItem[tokenID].sold = true;
        idToMarketItem[tokenID].seller = payable(address(0)); //Null

        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenID);
        payable(owner).transfer(listingPrice);
        payable(idToMarketItem[tokenID].seller).transfer(msg.value);
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint totalItemsInMarket = _tokenIDs.current();
        uint unsoldItemCount = _tokenIDs.current() - _itemsSold.current();
        uint currIndx = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);

        for (uint i = 0; i < totalItemsInMarket; i++) {
            bool isForSale = idToMarketItem[i + 1].owner == address(this);
            if (isForSale) {
                uint currID = i + 1;

                MarketItem storage currItem = idToMarketItem[currID];
                items[currIndx] = currItem;
                currIndx += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemsInMarket = _tokenIDs.current();
        uint itemCount = 0;
        uint currIndex = 0;

        for (uint i = 0; i < totalItemsInMarket; i++) {
            bool isOwner = idToMarketItem[i + 1].owner == msg.sender;
            if (isOwner) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemsInMarket; i++) {
            bool isOwner = idToMarketItem[i + 1].owner == msg.sender;
            if (isOwner) {
                uint currID = i + 1;

                MarketItem storage currItem = idToMarketItem[currID];
                items[currIndex] = currItem;
                currIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTsForSale() public view returns (MarketItem[] memory) {
        uint totalItemsInMarket = _tokenIDs.current();
        uint itemCount = 0;
        uint currIndex = 0;

        for (uint i = 0; i < totalItemsInMarket; i++) {
            bool isSeller = idToMarketItem[i + 1].seller == msg.sender;
            if (isSeller) {
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);

        for (uint i = 0; i < totalItemsInMarket; i++) {
            bool isSeller = idToMarketItem[i + 1].seller == msg.sender;
            if (isSeller) {
                uint currID = i + 1;

                MarketItem storage currItem = idToMarketItem[currID];
                items[currIndex] = currItem;
                currIndex += 1;
            }
        }
        return items; 
    }
}
