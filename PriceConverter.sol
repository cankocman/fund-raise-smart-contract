//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //Connecting to "Chainlink Oracle" to get the latest USD ETH ratio
    function getPrice() internal view returns (uint256) {
        // Need ABI of contract to interact
        // and address which is 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH to USD
        // This contract has 8 decimals but require function is in terms of WEI so has 18 decimals.
        return uint256(price * 1e10);
    }

    //Converting the "value" given in Wei to actual USD
    function getConversion(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();

        //ethPrice and ethAmount have 18 decimals since they are in Wei
        // so 36 zeros in total so we divide by 1e18
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUSD;
    }
}
