// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract FractionalNFT {
    address public originalOwner;
    address public nftContract;
    uint256 public tokenId;
    uint256 public totalShares;
    mapping(address => uint256) public shareBalances;
    address[] public shareholders;
    mapping(address => bool) private hasOwned;
    bool public isFractionalized;
    bool public isRedeemed;

    event Fractionalized(address indexed owner, uint256 totalShares);
    event ShareTransferred(address indexed from, address indexed to, uint256 amount);
    event Redeemed(address indexed redeemer);

    constructor() {
        originalOwner = msg.sender;
    }

    function fractionalize(address _nftContract, uint256 _tokenId, uint256 _totalShares) public {
        require(!isFractionalized, "Already fractionalized");
        require(msg.sender == originalOwner, "Only original owner can fractionalize");

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        nftContract = _nftContract;
        tokenId = _tokenId;
        totalShares = _totalShares;
        shareBalances[msg.sender] = _totalShares;

        // Add to shareholders
        shareholders.push(msg.sender);
        hasOwned[msg.sender] = true;

        isFractionalized = true;

        emit Fractionalized(msg.sender, _totalShares);
    }

    function transferShares(address to, uint256 amount) public {
        require(shareBalances[msg.sender] >= amount, "Insufficient shares");

        shareBalances[msg.sender] -= amount;
        shareBalances[to] += amount;

        // Track new shareholder if not previously added
        if (!hasOwned[to]) {
            shareholders.push(to);
            hasOwned[to] = true;
        }

        emit ShareTransferred(msg.sender, to, amount);
    }

    function redeem() public {
        require(shareBalances[msg.sender] == totalShares, "Must own all shares to redeem");
        require(!isRedeemed, "Already redeemed");

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        isRedeemed = true;

        emit Redeemed(msg.sender);
    }

    // 🆕 New function: View all current shareholders
    function getShareholders() public view returns (address[] memory) {
        return shareholders;
    }
}
