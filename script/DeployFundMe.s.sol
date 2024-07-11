// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns(FundMe) {
        vm.startBroadcast();

        // @todo This seems a little weird ... are the calls to vm.startBroadcast()
        // side effects for the test/* scripts? ... perhaps just a createFundMe()
        // method here, that both tests and script can call?
        FundMe instance = new FundMe({
            _pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        vm.stopBroadcast();

        return instance;
    }
}