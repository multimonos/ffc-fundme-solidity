// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * PriceConverter
 *
 * Deviated from the tutorial here as i didn't like
 * burying the call to Price Feed contract in a
 * library.
 */
library PriceConverter {
    function ethToUSD(uint256 ethAmount, uint256 ethPrice)
        public
        pure
        returns (uint256)
    {
        // why divide by 1e18 ... again, 1^18 * 1^18 = 1^(18+18) = 1^36
        uint256 usdPrice = (ethPrice * ethAmount) / 1e18;
        return usdPrice;
    }
}