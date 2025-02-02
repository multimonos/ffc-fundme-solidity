// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockPriceFeed} from "../test/mocks/MockPriceFeed.sol";

contract ConfigManager {

    struct NetworkConfig {
        string id;
        address priceFeedAddress;
    }

    // public
    uint8 public constant DECIMALS = 8;
    int256 public constant DEFAULT_PRICE = 3118e8;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;

    // private
    NetworkConfig private config;

    function get() public returns (NetworkConfig memory) {
        if (config.priceFeedAddress != address(0)) {
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
            id: "sepolia",
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function createAnvilConfig() private returns (NetworkConfig memory) {

        MockPriceFeed feed = new MockPriceFeed(DECIMALS, DEFAULT_PRICE);

        return NetworkConfig({
            id: "anvil",
            priceFeedAddress: address(feed)
        });
    }
}