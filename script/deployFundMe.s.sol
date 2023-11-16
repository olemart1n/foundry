// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {fundMe} from "../src/fundMe.sol";
import {helperConfig} from "./helperConfig.s.sol";

contract deployFundMe is Script {
    function run() external returns (fundMe) {
        helperConfig _helperConfig = new helperConfig();

        vm.startBroadcast();
        fundMe _fundMe = new fundMe(_helperConfig.activeNetworkConfig());
        vm.stopBroadcast();
        return _fundMe;
    }
}
