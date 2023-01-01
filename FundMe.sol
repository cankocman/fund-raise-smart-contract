// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    //Defining a minimum value of USD in order to fund
    //Multiplying it by 1e18 because of ETH to Wei ratio
    uint256 public minimumUSD = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    //Creating a "payable" function for funding and determining min. value
    // with "require"
    function fund() public payable {
        require(
            msg.value.getConversion() >= minimumUSD,
            "Did not send enough!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value.getConversion();
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funderAddress = funders[funderIndex];
            addressToAmountFunded[funderAddress] = 0;
        }

        //reset the array
        funders = new address[](0);

        //withdrawing has 3 options:
        //transfer is capped at 2300gas and if overlimit throws an error
        payable(msg.sender).transfer(address(this).balance);
        //send is capped at 2300gas and returns bool
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Sending failed.");
        //call has no cap and returns bool
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed.");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }
}
