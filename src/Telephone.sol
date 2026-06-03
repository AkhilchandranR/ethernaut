// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

// if an attacker calls from contract A to contract B,
// then, In Contract A 
// tx.origin = attacker and msg.sender = attacker
// but in Contract B
// tx.origin = attacker (as it originated from there) 
// and msg.sender = contract. 
    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}