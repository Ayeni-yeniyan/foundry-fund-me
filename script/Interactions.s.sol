// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMEME} from "../src/Fundme.sol";

//Fund
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMEME(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMEME with %s", SEND_VALUE);
    }
}

// Withdraw
contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }

    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMEME(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawn FundMEME with %s", SEND_VALUE);
    }
}
