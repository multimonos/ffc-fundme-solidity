// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {ConfigManager} from "../src/ConfigManager.sol";

contract FundMeTest is Test {

    FundMe public fundme;

    address public owner;
    address public funder;

    struct Donor {
        address addr;
        uint256 amount;
    }

    function setUp() public {

        owner = makeAddr("owner");
        funder = makeAddr("funder");

        ConfigManager config = new ConfigManager();
//        console.log("config: %s", config.get().id);

//        hoax(owner, 0 ether); // fails to set "our" owner as expected
//        vm.prank(owner); // fails to set "our" owner as expected
        vm.startPrank(owner);
        fundme = new FundMe({
            priceFeed: config.get().priceFeedAddress
        });
        vm.stopPrank();
    }

    function test_owner_is_not_this() public view {
        assertNotEq(fundme.owner(), address(this));
    }

    function test_owner_set() public view {
        assertEq(fundme.owner(), owner);
    }

    function test_msg_sender_is_not_this() public view {
        assertNotEq(address(this), msg.sender);
    }

    function test_ini_balance_zero() public view {
        assertEq(fundme.balance(), 0);
    }

    function test_min_usd() public view {
        assertEq(fundme.MIN_USD(), 5e18);
    }

    function test_fund_requires_min_ether() public {
        vm.expectRevert(FundMe.InsufficientPayment.selector);
        fundme.fund();
    }

    function test_was_funded() public {
        hoax(funder, 2 ether);
        fundme.fund{value: funder.balance}();
        assertEq(address(fundme).balance, 2 ether);
    }

    function test_funder_isset() public {
        hoax(funder, 2 ether);
        fundme.fund{value: 2 ether}();
        assertEq(funder, fundme.funders(0));
    }

    function test_funder_amount_isset() public {
        hoax(funder, 2 ether);
        fundme.fund{value: 2 ether}();
        assertEq(fundme.funderAmount(funder), 2 ether);
    }

    function test_funder_can_accumlate_funds() public {
        vm.deal(funder, 5 ether);
        vm.startPrank(funder);
        fundme.fund{value: 2 ether}();
        fundme.fund{value: 2 ether}();
        vm.stopPrank();
        assertEq(fundme.funderAmount(funder), 4 ether);
    }

    function test_not_owner_fails_to_withdraw() public {
        address user = address(0x7);
        vm.expectRevert(
            abi.encodeWithSelector(FundMe.OnlyOwner.selector, user)
        );
        vm.prank(user);
        fundme.withdraw();
    }

    function test_owner_can_withdraw() public {
        vm.prank(owner);
        fundme.withdraw();
    }

    function test_withdraw_after_one_deposit() public {
        // depsit
        hoax(funder, 3 ether);
        fundme.fund{value: 3 ether}();
        // intermediate state
        assertEq(owner.balance, 0);
        assertEq(fundme.balance(), 3 ether);
        // withdraw
        vm.prank(owner);
        fundme.withdraw();
        // final state
        assertEq(owner.balance, 3 ether);
        assertEq(fundme.balance(), 0 ether);
    }

    function test_withdraw_after_many_deposits() public {
        Donor[3] memory donors;
        donors[0] = Donor(address(0x5), 3 ether);
        donors[1] = Donor(address(0x6), 2 ether);
        donors[2] = Donor(address(0x6), 5 ether);

        //deposit
        uint256 total = 0;
        for (uint160 i = 0; i < donors.length; i++) {
            Donor memory donor = donors[i];
            hoax(donor.addr, donor.amount);
            fundme.fund{value: donor.amount}();
            total += donor.amount;
        }
        assertEq(fundme.balance(), total);
        // withdraw
        vm.prank(owner);
        fundme.withdraw();
        // final state
        assertEq(fundme.balance(), 0);
        assertEq(owner.balance, total);
    }


    function test_funders_reset_after_withdraw() public {
        Donor[3] memory donors;
        donors[0] = Donor(address(0x5), 3 ether);
        donors[1] = Donor(address(0x6), 2 ether);
        donors[2] = Donor(address(0x6), 5 ether);

        //deposit
        uint256 total = 0;
        for (uint160 i = 0; i < donors.length; i++) {
            Donor memory donor = donors[i];
            hoax(donor.addr, donor.amount);
            fundme.fund{value: donor.amount}();
            total += donor.amount;
        }
        assertEq(fundme.balance(), total);
        // withdraw
        vm.prank(owner);
        fundme.withdraw();
        // final state
        for (uint i = 0; i < donors.length; i++) {
            assertEq(fundme.funderAmount(donors[i].addr), 0);
        }
    }

    function test_empty_fn_call_accepts_funds() public {
        hoax(address(0x13), 5 ether);
        (bool ok,) = address(fundme).call{value: 5 ether}("");
        assertEq(fundme.balance(), 5 ether);
        assertTrue(ok);
    }

    function test_invalid_fn_call_accepts_funds() public {
        hoax(address(0x13), 5 ether);
        (bool ok,) = address(fundme).call{value: 5 ether}("functionDoesNotExist()");
        assertEq(fundme.balance(), 5 ether);
        assertTrue(ok);
    }
//
//    function test_fallback_funder_attribution() public {
//        address foobar = makeAddr("foobar");
//        vm.deal(foobar, 10 ether);
//        vm.prank(foobar);
//        address(fundme).call{value: 5 ether}("");
//        assertEq(fundme.funderAmount(foobar), 5 ether);
//    }

//    function test_get_price() public {
//        ConfigManager mgr = new ConfigManager();
//        console.log("price: %s", mgr.DEFAULT_PRICE());
//        assertTrue(true);
//    }
}
