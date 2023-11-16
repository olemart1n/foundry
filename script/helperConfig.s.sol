// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {mockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract helperConfig is Script {
    struct networkConfig {
        address priceFeed; // ETH/USD address
    }

    networkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL_COUNT = 8;
    int256 public constant ETH_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (networkConfig memory) {
        //pricefeed address
        networkConfig memory sepoliaConfig = networkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (networkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        mockV3Aggregator _mockV3Aggregator = new mockV3Aggregator(DECIMAL_COUNT, ETH_PRICE);
        vm.stopBroadcast();

        networkConfig memory anvilConfig = networkConfig({priceFeed: address(_mockV3Aggregator)});
        return anvilConfig;
    }
}
