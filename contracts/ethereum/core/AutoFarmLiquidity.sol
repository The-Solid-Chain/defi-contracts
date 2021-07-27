// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Helps providing liquidity to PancakeSwap and staking the LP tokens into a staking pool all
    in one operation
 */

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@thesolidchain/pancake-swap-periphery/contracts/interfaces/IPancakeRouter02.sol";

import "./BaseFarmDelegated.sol";

contract AutoFarmLiquidity is Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 _token0;
    IERC20 _token1;
    IERC20 _lptoken;
    IBaseFarmDelegated _lpTokenPool;
    IPancakeRouter02 _pancakeRouter;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        IERC20 token0,
        IERC20 token1,
        IERC20 lptoken,
        IBaseFarmDelegated lpTokenPool,
        IPancakeRouter02 pancakeRouter
    ) {
        _token0 = token0;
        _token1 = token1;
        _lptoken = lptoken;
        _lpTokenPool = lpTokenPool;
        _pancakeRouter = pancakeRouter;

        _token0.approve(address(_pancakeRouter), type(uint256).max);
        _token1.approve(address(_pancakeRouter), type(uint256).max);
        _lptoken.approve(address(_lpTokenPool), type(uint256).max);
        _lptoken.approve(address(_pancakeRouter), type(uint256).max);
    }

    /* ========== MUTABLES ========== */
    function stake(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 deadline
    ) public {
        _token0.safeTransferFrom(_msgSender(), address(this), amount0Desired);
        _token1.safeTransferFrom(_msgSender(), address(this), amount1Desired);

        (uint256 amount0, uint256 amount1, uint256 liquidity) = _pancakeRouter.addLiquidity(
            address(_token0),
            address(_token1),
            amount0Desired,
            amount1Desired,
            amount0Min,
            amount1Min,
            address(this),
            deadline
        );
        require(liquidity > 0, "Received 0 liquidity from Router");

        // Returned unused tokens
        if (amount0 != amount0Desired) {
            _token0.safeTransfer(_msgSender(), amount0Desired - amount0);
        }
        if (amount1 != amount1Desired) {
            _token1.safeTransfer(_msgSender(), amount1Desired - amount1);
        }

        _lpTokenPool.stake(liquidity, _msgSender());
    }

    function withdraw(
        uint256 liquidity,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 deadline
    ) public {
        _lpTokenPool.withdraw(liquidity, _msgSender());
        _pancakeRouter.removeLiquidity(
            address(_token0),
            address(_token1),
            liquidity,
            amount0Min,
            amount1Min,
            _msgSender(),
            deadline
        );
    }

    function exit(uint256 deadline) external {
        uint256 liquidity = _lpTokenPool.exit(_msgSender());
        _pancakeRouter.removeLiquidity(address(_token0), address(_token1), liquidity, 0, 0, _msgSender(), deadline);
    }
}
