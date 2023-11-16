// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {fundMe} from "../../src/fundMe.sol";
import {deployFundMe} from "../../script/deployFundMe.s.sol";
import {fundFundMe} from "../../script/interactions.s.sol";

contract testInteractions is Test {
    fundMe _fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        deployFundMe deploy = new deployFundMe();
        _fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        fundFundMe _fundFundMe = new fundFundMe();
        _fundFundMe.fund(address(_fundMe));
    }
}
