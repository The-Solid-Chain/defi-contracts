// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../core/BaseERC20.sol";

contract MockBUSD is BaseERC20 {
    constructor() BaseERC20("BUSD", "BUSD") {}
}
