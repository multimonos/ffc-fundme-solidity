// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";
import {MockPriceFeed} from "../test/mocks/MockPriceFeed.sol";

contract ConfigManager {

    uint8 public constant DECIMALS = 8;
    int256 public constant DEFAULT_PRICE = 3118e8;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;

    struct NetworkConfig {
        string ID;
        address PriceFeedAddress;
    }

    NetworkConfig private config;

    function get() public returns (NetworkConfig memory) {
        if (config.PriceFeedAddress != address(0)) {
            return config;
        }

        if (SEPOLIA_CHAIN_ID == block.chainid) {
            config = createSepoliaConfig();
        } else {
            config = createDefaultConfig();
        }

        return config;
    }

    function createDefaultConfig() private returns (NetworkConfig memory) {
        return createAnvilConfig();
    }

    function createSepoliaConfig() private pure returns (NetworkConfig memory){
        return NetworkConfig({
            ID: "sepolia",
            PriceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function createAnvilConfig() private returns (NetworkConfig memory) {

        MockPriceFeed feed = new MockPriceFeed(DECIMALS, DEFAULT_PRICE);

        return NetworkConfig({
            ID: "anvil",
            PriceFeedAddress: address(feed)
        });
    }
}