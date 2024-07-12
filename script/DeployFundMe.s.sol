// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {ConfigManager} from "../src/ConfigManager.sol";

contract DeployFundMe is Script {
    function run() external {

        // trying a simpler pattern here.
        ConfigManager config = new ConfigManager();


        vm.startBroadcast();

        // gas cost starts here.

        new FundMe({
            priceFeed: config.get().priceFeedAddress
        });

        vm.stopBroadcast();

    }
}