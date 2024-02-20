// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "prb-math/PRBMath.sol";

library Math {
    function calcAmount0Delta(
        uint160 sqrtPriceAX96,
        uint160 sqrtPriceBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtPriceAX96 > sqrtPriceBX96)
        (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

        require(sqrtPriceAX96 > 0);

          amount0 = divRoundingUp(
        mulDivRoundingUp(
            (uint256(liquidity) << FixedPoint96.RESOLUTION),
            (sqrtPriceBX96 - sqrtPriceAX96),
            sqrtPriceBX96
        ),
        sqrtPriceAX96
    );
    }
    
}