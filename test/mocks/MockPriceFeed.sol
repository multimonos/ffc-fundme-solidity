// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract MockPriceFeed is MockV3Aggregator {

    // Seems like the MockV3Aggregator has a strange design choice.
    // ... why is the specificity of `version` more limited below than
    // in the parent class.
    //
    // uint256 public constant override version = 0;
    //
    // suggest remove "constant" so any dev can easily return
    // their own value for version

    constructor(uint8 _decimals, int256 _initialAnswer) MockV3Aggregator(_decimals, _initialAnswer) {
    }
}
