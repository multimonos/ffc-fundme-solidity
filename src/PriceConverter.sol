// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PriceConverter {

    function ethToUSD(uint256 ethAmount, uint256 ethPrice) public pure returns (uint256){
        uint256 usdPrice = (ethPrice * ethAmount) / 1e18;
        // why divide by 1e18 ... again, 1^18 * 1^18 = 1^(18+18) = 1^36
        return usdPrice;
    }

}