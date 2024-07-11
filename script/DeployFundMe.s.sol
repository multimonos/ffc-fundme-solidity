// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {ConfigManager} from "./ConfigManager.s.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe) {

        // not a real txn ... no gas const
        ConfigManager config = new ConfigManager();

        address pricefeedAddress = config.get().PriceFeedAddress;

        vm.startBroadcast();
        // gas cost starts here.


        // @todo This seems a little weird ... are the calls to vm.startBroadcast()
        // side effects for the test/* scripts? ... perhaps just a createFundMe()
        // method here, that both tests and script can call?
        FundMe instance = new FundMe({
            _pricefeed: pricefeedAddress
        });

        vm.stopBroadcast();

        return instance;
    }
}