// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {fundMe} from "../src/fundMe.sol";
// FUND
// WITHDRAW

contract fundFundMe is Script {
    function fund(address mostRecentDeployed) public {
        uint256 SEND_VALUE = 0.01 ether;
        vm.startBroadcast();
        fundMe(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("funded the contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployd = DevOpsTools.get_most_recent_deployment("fundMe", block.chainid);
    }
}

contract withdrawFundMe is Script {
    function withdraw(address mostRecentDeployed) public {
        fundMe(payable(mostRecentDeployed)).withdraw();
    }

    function run() external {
        address mostRecentlyDeployd = DevOpsTools.get_most_recent_deployment("fundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployd);
        vm.stopBroadcast();
    }
}
