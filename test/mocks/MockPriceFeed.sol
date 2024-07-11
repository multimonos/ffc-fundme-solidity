// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract MockPriceFeed is MockV3Aggregator {
    constructor(uint8 _decimals, int256 _initialAnswer) MockV3Aggregator(_decimals, _initialAnswer) {
    }
}
