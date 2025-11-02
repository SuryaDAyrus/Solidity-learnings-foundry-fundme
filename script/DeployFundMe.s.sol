// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Get the price feed address for your network
       HelperConfig helperConfig = new HelperConfig();
        // address ethUsdPriceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // Example: Sepolia ETH/USD feed
        address ethUsdPriceFeed = helperConfig.getOrCreateAnvilEthConfig();

         // Deploy the FundMe contract
        vm.startBroadcast();
         FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
