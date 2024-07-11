// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

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

    using PriceConverter for uint256;
    address immutable public owner; // "immutable" saves gas
    uint256 public constant MIN_USD = 5e18;

    AggregatorV3Interface immutable private pricefeed;

    address[] public funders;
    mapping(address funder => uint256 amount) public funderAmount;

    error OnlyOwner(); //saves 10,000 gas
    error InsufficientPayment(); //saves 10,000 gas

    modifier onlyOwner {
        if (owner != msg.sender) revert OnlyOwner();
        _;
    }

    constructor(address _pricefeed) {
        owner = msg.sender;
        pricefeed = AggregatorV3Interface(_pricefeed);
    }

    function fund() public payable {
        uint256 ethPrice = getPrice();
        if (msg.value.ethToUSD(ethPrice) < MIN_USD) revert InsufficientPayment();
        funders.push(msg.sender);
        funderAmount[msg.sender] = funderAmount[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
        // reset funders
        for (uint i = 0; i < funders.length; i++) {
            address funder = funders[i];
            funderAmount[funder] = 0;
        }
        funders = new address[](0);

        // xfer to owner
        (bool ok,) = payable(owner).call{value: address(this).balance}("");
        require(ok, "failed to withdraw funds");
    }

    function getFeedVersion() public view returns (uint256){
        return pricefeed.version();
    }

    function getPrice() public view returns (uint256){
        (,int256 answer,,,) = pricefeed.latestRoundData();
        // why x*1e10 ... answer returned with 8 decimals, but, wei is e18
        // recall 1^10 * 1^8 = 1^(10 + 8) = 1^18
        // ...,so, we normalize the precision.
//        int256 answer = 3119258696210000000000;
        uint256 price = uint256(answer) * 1e10;

        return price;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund(); // why payable? isn't this covered by receive()?
    }

}