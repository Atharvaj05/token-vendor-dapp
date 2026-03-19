pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    /////////////////
    /// Errors //////
    /////////////////
    error InvalidEthAmount();
error InsufficientVendorTokenBalance(uint256 available, uint256 required);
    // Errors go here...
    error EthTransferFailed(address to, uint256 amount);
    error InvalidTokenAmount();
error InsufficientVendorEthBalance(uint256 available, uint256 required);

event SellTokens(address indexed seller, uint256 amountOfTokens, uint256 amountOfETH);
    //////////////////////
    /// State Variables //
    //////////////////////
    uint256 public constant tokensPerEth = 100;
    YourToken public immutable yourToken;

    ////////////////
    /// Events /////
    ////////////////

    // Events go here...
    event BuyTokens(address indexed buyer, uint256 amountOfETH, uint256 amountOfTokens);
    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function buyTokens() external payable {
        if (msg.value == 0) revert InvalidEthAmount();

    uint256 amountOfTokens = msg.value * tokensPerEth;
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    if (vendorBalance < amountOfTokens) revert InsufficientVendorTokenBalance(vendorBalance, amountOfTokens);

    yourToken.transfer(msg.sender, amountOfTokens);
    emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }
    function withdraw() external onlyOwner {
    uint256 amount = address(this).balance;
    (bool success,) = owner().call{value: amount}("");
    if (!success) revert EthTransferFailed(owner(), amount);
}
    // function withdraw() public onlyOwner {}
    function sellTokens(uint256 amount) external {
    if (amount == 0) revert InvalidTokenAmount();

    uint256 amountOfETH = amount / tokensPerEth;
    uint256 vendorEthBalance = address(this).balance;
    if (vendorEthBalance < amountOfETH) revert InsufficientVendorEthBalance(vendorEthBalance, amountOfETH);

    yourToken.transferFrom(msg.sender, address(this), amount);

    (bool success,) = msg.sender.call{value: amountOfETH}("");
    if (!success) revert EthTransferFailed(msg.sender, amountOfETH);

    emit SellTokens(msg.sender, amount, amountOfETH);
}
    // function sellTokens(uint256 amount) public {}
}
