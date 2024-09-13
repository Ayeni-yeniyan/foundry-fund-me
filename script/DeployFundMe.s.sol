// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import {FundMEME} from "../src/Fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {Script} from "forge-std/Script.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMEME) {
        HelperConfig helperConfig = new HelperConfig();
        address activeNetworkConfig = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMEME fundMe = new FundMEME(activeNetworkConfig);
        vm.stopBroadcast();
        return fundMe;
    }
}
