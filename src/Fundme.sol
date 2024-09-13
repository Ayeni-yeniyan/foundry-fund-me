// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

// Custom errors? read up on it
error FundMe_NotOwner();

contract FundMEME {
    // Constants and immutables reduce gas cost when you are only setting the variables once.
    // constants are use when you create the variable similar to const in flutter
    // immutable is similar to final where you can only assign the value of the variable once.
    // 1e10 is one ethereum???
    uint256 public constant MINIMUN_USD = 5e18;
    // Using libraries like extensions in dart
    using PriceConverter for uint256;
    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // This receive is a special function triggered when you send eth with interacting with the fund function itself
    // calling [fund()] to ensure we store the customer details
    receive() external payable {
        fund();
    }

    // This is a special functions triggered when a data is sent with the transaction.
    // This is fall back since receive can't handle data inputs, only empty transactions.
    fallback() external payable {
        fund();
    }

    // store the address that sent us eth
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    function fund() public payable {
        require(
            msg.value.convertToUsd(s_priceFeed) >= MINIMUN_USD,
            "Eth sent is not enough"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            msg.value +
            s_addressToAmountFunded[msg.sender];
    }

    function withdraw() public ownerOnly {
        // must be the owner to withdraw from contract balance
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        // Three ways to transfer to a wallet
        // you have to make the address payable
        // Transfer will send and automatically check/ revert if the transaction fails
        // payable (msg.sender).transfer(address(this).balance);
        // Send will return a bool without reverting. You should revert yourself based on the bool with a required check
        //    bool transactionSuccessful= payable (msg.sender).send(address(this).balance);
        //     require(transactionSuccessful,"You can't withdraw at this moment");
        // call is a powerful low level function. Prefer to use it.
        (bool tSuccess /* bytes dataReturned*/, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(tSuccess, "You can't withdraw at this moment");
    }

    function showversion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // Modifiers are essentiall functions that can be prefixed to a fuction. the _ refers to the other functions functionality
    modifier ownerOnly() {
        require(
            msg.sender == i_owner,
            "You must be the owner of the contract to perform this action!!!"
        );
        _; /*This means the function actions that you have attached this contract to.*/
    }

    /**
     * Getter Functions
     */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
