// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {fundMe} from "../../src/fundMe.sol";
import {deployFundMe} from "../../script/deployFundMe.s.sol";

contract fundMeTest is Test {
    fundMe public _fundMe;
    uint256 constant SEND_VALUE = 10e17;
    address USER = makeAddr("user");
    uint256 STARTING_USER_BALANCE = 100e18;

    function setUp() external {
        deployFundMe _deployFundMe = new deployFundMe();
        _fundMe = _deployFundMe.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    modifier funded() {
        vm.prank(USER);
        _fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testMinimumDollarIsFive() public {
        assertEq(_fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(_fundMe.getOwner(), msg.sender);
    }

    function testFundFailWithOutEnoughEth() public {
        vm.expectRevert(); // expect function to fail
        _fundMe.fund(); // send value 0
    }

    function testFundUpdatesFundedDataStructure() public funded {
        console.log("value is sent from user");
        uint256 amountFunded = _fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsUserToFundersArray() public funded {
        address funder = _fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        _fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startBalanceSender = _fundMe.getOwner().balance;
        uint256 startBalanceContract = address(_fundMe).balance;
        // Act
        vm.prank(_fundMe.getOwner());
        uint256 gasStart = gasleft();
        vm.txGasPrice(1); // SPENDING GAS

        _fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        // Assert
        uint256 endBalanceSender = _fundMe.getOwner().balance;
        uint256 endBalanceContract = address(_fundMe).balance;
        assertEq(endBalanceContract, 0);
        assertEq(startBalanceContract + startBalanceSender, endBalanceSender);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; startingFunderIndex > numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            _fundMe.fund{value: SEND_VALUE}();
        }
        // Act

        vm.startPrank(_fundMe.getOwner());

        _fundMe.withdraw();

        // Assert
        vm.stopPrank();
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; startingFunderIndex > numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            _fundMe.fund{value: SEND_VALUE}();
        }
        // Act

        vm.startPrank(_fundMe.getOwner());

        _fundMe.cheaperWithdraw();

        // Assert
        vm.stopPrank();
    }
}
