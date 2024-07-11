// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {ConfigManager} from "../script/ConfigManager.s.sol";

contract FundMeTest is Test {

    FundMe public ins;
    DeployFundMe public deployer;

    address public owner = makeAddr("owner");
    address public funder = makeAddr("funder");
    address public constant PRICEFEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;


    function setUp() external {
        deployer = new DeployFundMe();
        ins = deployer.run();
    }

    function test_addresses() public view {
        console.log("deployer: %s", address(deployer));
        console.log("msg.sender: %s", address(msg.sender));
        console.log("this: %s", address(this));
        console.log("ins.owner: %s", address(ins.owner()));
        assertTrue(true);
    }

    function test_ini_balance_zero() public view {
        assertEq(address(ins).balance, 0);
    }

    function test_min_usd() public view {
        assertEq(ins.MIN_USD(), 5e18);
    }

    function test_owner_is_sender() public view {
        // there is a default msg.sender controlled by foundry
        assertEq(address(msg.sender), ins.owner());
    }

//    function test_price_feed_version() public view {
//        assertEq(ins.getFeedVersion(), 4);
//    }

    function test_fund_requires_min_eth() public {
        vm.expectRevert();
        vm.deal(funder, 10 ether);
        vm.prank(funder);
        ins.fund{value: 1 wei}();
    }

    function test_can_fund() public {
        ins.fund{value: 2e15 wei}();
        assertEq(address(ins).balance, 2e15 wei);
    }

    function test_funder_attribution() public {
        vm.deal(funder, 10 ether);
        vm.startPrank(funder);
        ins.fund{value: 2 ether}();
        ins.fund{value: 2 ether}();
        vm.stopPrank();

        assertEq(funder.balance, 6 ether);
        assertEq(ins.funderAmount(funder), 4 ether);
    }

    function test_only_owner_can_withdraw() public {
        vm.prank(address(7));
        vm.expectRevert();
        ins.withdraw();
    }

    function test_withdraw() public {
        vm.deal(funder, 10 ether);
        vm.startPrank(funder);
        ins.fund{value: 2 ether}();
        ins.fund{value: 3 ether}();
        ins.fund{value: 1 ether}();
        vm.stopPrank();

        assertEq(address(ins).balance, 6 ether);
        assertEq(address(funder).balance, 4 ether);

        uint256 ogbalance = msg.sender.balance;
        vm.prank(msg.sender);
        ins.withdraw();
        assertEq(address(msg.sender), address(ins.owner()));

        assertEq(address(ins).balance, 0, "contract balance is zero");
        assertEq(ins.funderAmount(funder), 0, "funder balance reset");
        assertEq(address(msg.sender).balance, ogbalance + 6 ether, "owner receives entire balance");
    }


    function test_payable_fallback_exists() public {
        address foobar = makeAddr("foobar");
        vm.deal(foobar, 10 ether);
        vm.prank(foobar);
        address(ins).call{value: 5 ether}("anything()");
        assertEq(address(ins).balance, 5 ether);
    }

    function test_fallback_funder_attribution() public {
        address foobar = makeAddr("foobar");
        vm.deal(foobar, 10 ether);
        vm.prank(foobar);
        address(ins).call{value: 5 ether}("");
        assertEq(ins.funderAmount(foobar), 5 ether);
    }

//    function test_get_price() public {
//        ConfigManager mgr = new ConfigManager();
//        console.log("price: %s", mgr.DEFAULT_PRICE());
//        assertTrue(true);
//    }
}
