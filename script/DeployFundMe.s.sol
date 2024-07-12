// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {ConfigManager} from "../src/ConfigManager.sol";

contract DeployFundMe is Script {
    function run() external {

        // not a real txn ... no gas const
        ConfigManager config = new ConfigManager();

        vm.startBroadcast();
        // gas cost starts here.

        // @todo This seems a little weird ... are the calls to vm.startBroadcast()
        // side effects for the test/* scripts? ... perhaps just a createFundMe()
        // method here, that both tests and script can call?
        new FundMe({
            priceFeed: config.get().priceFeedAddress
        });

        vm.stopBroadcast();

    }
}