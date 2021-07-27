// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Currency token of the system
 */
import "../core/BaseERC20.sol";

contract ExampleERC20Token is BaseERC20 {
    constructor() BaseERC20("ExampleToken", "EXT") {}
}
