// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {

    FundMe public ins;

    address public owner = makeAddr("owner");
    address public funder = makeAddr("funder");
    address public constant PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;


    function setUp() external {
        ins = new FundMe(PRICEFEED);
    }

    function test_ini_balance_zero() public view {
        assertEq(address(ins).balance, 0);
    }

    function test_min_usd() public view {
        assertEq(ins.MIN_USD(), 5e18);
    }

    function test_owner_is_sender() public view {
        // FundMeTest is owner.
        assertEq(address(this), ins.owner());
    }

    function test_price_feed_version() public view {
        assertEq(ins.getFeedVersion(), 4);
    }

//    function test_approximate_eth2usd_rate() public {
//        uint256 rate = ins.getConversionRate();
//        console.log("rate: %s",rate);
//    }

    function test_fund_requires_min_eth() public {
        hoax(funder, 10 ether);
        vm.expectRevert();
        ins.fund{value: 1 wei}();
    }

    function test_can_fund() public {
        ins.fund{value: 2e15 wei}();
        assertEq(address(ins).balance, 2e15 wei);
    }

//    function test_funder_attribution() public {
//        startHoax(funder, 10 ether);
//        ins.fund{value: 2 ether}();
//        ins.fund{value: 2 ether}();
//        vm.stopPrank();
//
//        assertEq(funder.balance, 6 ether);
//        assertEq(ins.funderAmount(funder), 4 ether);
//    }
//
//    function test_withdraw() public {
//
//        startHoax(funder, 10 ether);
//        ins.fund{value: 2 ether}();
//        ins.fund{value: 3 ether}();
//        ins.fund{value: 1 ether}();
//        vm.stopPrank();
//
//        assertEq(address(ins).balance, 6 ether);
//        assertEq(address(funder).balance, 4 ether);
//
////        vm.prank(address(this));
//        ins.withdraw();
//
//        assertEq(address(ins).balance, 0, "contract balance is zero");
//        assertEq(address(this).balance, 6 ether, "owner receives entire balance");
//        assertEq(ins.funderAmount(funder), 0, "funder balance reset");
//    }
//
//    function test_withdraw_only_owner() public {
//        vm.prank(address(7));
//        vm.expectRevert();
//        ins.withdraw();
//    }
//
//    function test_payable_fallback_exists() public {
//        address foobar = makeAddr("foobar");
//        hoax(foobar, 10 ether);
//        address(ins).call{value: 5 ether}("");
//        assertEq(address(ins).balance, 5 ether);
//    }
//
//    function test_fallback_funder_attribution() public {
//        address foobar = makeAddr("foobar");
//        hoax(foobar, 10 ether);
//        address(ins).call{value: 5 ether}("");
//        assertEq(ins.funderAmount(foobar), 5 ether);
//    }
}
