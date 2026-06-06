// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
    */
}

// POC :- in the test, deploy this contract, then call setSolver with this contract 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Factory {
    event Log(address addr);

    // Deploys a contract that always returns 42 , this is from solidity by exmaple
    function deploy() external {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            // create(value, offset, size)
            // 0x13 in hex is 19 in decimal (the exact byte length of the bytecode)
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
        require(addr != address(0), "Deployment failed");

        emit Log(addr);
    }
}