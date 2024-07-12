// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {console} from "forge-std/console.sol";

/**
* FundMe
*
* Requirements
* - users can donate funds
* - require minimum donation value in USD
* - convert eth to usd using chainlink price fee
* - owner can withdraw balance
*/
contract FundMe {
    //mix
    using PriceConverter for uint256;
    //pub
    uint256 public constant MIN_USD = 5e18;
    address public immutable owner; // "immutable" saves gas
    address[] public funders;
    mapping(address funder => uint256 amount) public funderAmount;
    //priv
    AggregatorV3Interface immutable private pricefeed;
    //err
    error OnlyOwner(address); //saves 10,000 gas
    error InsufficientPayment(); //saves 10,000 gas
    error WithdrawlFailed(address);
    //mod
    modifier onlyOwner {
        if (msg.sender != owner) revert OnlyOwner(msg.sender);
        _;
    }
    //fns
    constructor(address _pricefeed) {
        owner = msg.sender;
        pricefeed = AggregatorV3Interface(_pricefeed);
    }

    receive() external payable {
        fund();
        console.log("receive() called when call('') empty");
    }

    fallback() external payable {
        fund();
        console.log("fallback() called when call('something()') non-empty");
    }

    function withdraw() external onlyOwner {
        // reset funder amounts
        uint len = funders.length;
        for (uint i = 0; i < len; i++) {
            address funder = funders[i];
            funderAmount[funder] = 0;
        }

        // reset funders
        funders = new address[](0);

        // xfer to owner
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) revert WithdrawlFailed(msg.sender);
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function fund() public payable {
        uint256 ethPrice = getPrice();
        if (msg.value.ethToUSD(ethPrice) < MIN_USD) revert InsufficientPayment();
        funders.push(msg.sender);
        funderAmount[msg.sender] = funderAmount[msg.sender] + msg.value;
    }

    function getPrice() public view returns (uint256) {
        (,int256 answer,,,) = pricefeed.latestRoundData();
        // why answer * 1e10 ... answer returned with 8 decimals, but, wei is e18
        // recall 1^10 * 1^8 = 1^(10 + 8) = 1^18 ..., so, we normalize the precision.
        return  uint256(answer) * 1e10;
    }
}