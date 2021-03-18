//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.10;

contract Evaluationablebadge {
    address payable creator;

    constructor() public{
        creator = msg.sender;
    }

    // TODO Add functions

    function kill() public {
        if (msg.sender == creator) {
            selfdestruct(creator);
        }
    }
}
