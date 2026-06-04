// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

// Compiler successfully neutralizes this bug. 
// using vm.expectRevert() to prove that
contract TokenTest is Test {
    Token token;
    address attacker = makeAddr("attacker");
    uint256 initialSupply = 100 ether;

    function setUp() public {
        token = new Token(initialSupply);
        vm.deal(attacker, 0 ether);
    }

    function testAttackerCanStealTokens() public {
        address user = makeAddr("user");
        //assert attacker's balance is 0, so to enable underflow.
        assertEq(address(attacker).balance, 0);
        // Call transfer with 1 ether
        vm.startPrank(attacker);
        vm.expectRevert();
        token.transfer(user, 1);
        // assert for user's token to be maximum
        assertEq(address(attacker).balance, 0);
        vm.stopPrank();
    }
}