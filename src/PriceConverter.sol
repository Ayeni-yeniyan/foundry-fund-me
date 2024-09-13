// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    function checkDecimals(
        AggregatorV3Interface priceFeed
    ) public view returns (uint8) {
        return priceFeed.decimals();
    }

    function convertToUsd(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethInUsdAmount = (ethPrice * ethAmount) / 1e10;
        return ethInUsdAmount;
    }
}
