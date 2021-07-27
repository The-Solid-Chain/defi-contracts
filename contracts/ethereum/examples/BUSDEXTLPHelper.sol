// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Helper for providing liquidity to a the EXT-BUSD pool
 */
import "../core/AutoFarmLiquidity.sol";

contract BUSDEXTLPHelper is AutoFarmLiquidity {
    constructor(
        IERC20 token0,
        IERC20 token1,
        IERC20 lpToken,
        IBaseFarmDelegated lpTokenPool,
        IPancakeRouter02 pancakeRouter
    ) AutoFarmLiquidity(token0, token1, lpToken, lpTokenPool, pancakeRouter) {}
}
