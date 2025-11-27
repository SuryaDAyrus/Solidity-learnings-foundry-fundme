// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Create HelperConfig instance
        HelperConfig helperConfig = new HelperConfig();

        // Get the network config struct
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getOrCreateAnvilEthConfig();

        // Extract the address from it
        address ethUsdPriceFeed = networkConfig.priceFeed;

        // Deploy FundMe contract
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}

