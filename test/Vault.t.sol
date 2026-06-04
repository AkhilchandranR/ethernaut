// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    Vault vaultContract;
    bytes32 password = bytes32("secret_password");

    function setUp() public {
        vaultContract = new Vault(password);
    }

    function testPasswordCanBeReadFromStorage() public {
        // assert the contract is locked
        assert(vaultContract.locked());
        // retreive the password
        bytes32 secret = vm.load(address(vaultContract), bytes32(uint256(1)));
        // call the unlock() function
        vaultContract.unlock(secret);
        // assert contract is unlocked
        assertFalse(vaultContract.locked());
    }
}