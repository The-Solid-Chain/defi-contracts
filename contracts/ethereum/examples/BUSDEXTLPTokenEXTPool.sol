// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    EXTBUSD-LP token pool. LP tokens staked here will generate EXT Token rewards
    to the holder
 */

import "../core/FarmDelegated.sol";

contract BUSDEXTLPTokenEXTPool is FarmDelegated {
    constructor(
        IERC20 extToken_,
        IERC20 lpToken_,
        uint256 startTime_
    ) FarmDelegated(extToken_, lpToken_, startTime_) {}
}
