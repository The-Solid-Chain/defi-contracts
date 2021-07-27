// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
    Token faucet to refill tokens to the caller up to a maximum amount
 */
contract Faucet is Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20[] public tokens;
    uint256 public maxAmount;
    mapping(address => bool) public admins;

    constructor(
        IERC20[] memory _tokens,
        uint256 _maxAmount,
        address[] memory _admins
    ) {
        tokens = _tokens;
        maxAmount = _maxAmount;

        for (uint256 i = 0; i < _admins.length; ++i) {
            admins[_admins[i]] = true;
        }
    }

    function refill() public {
        uint256 refillAmount = maxAmount;

        if (admins[_msgSender()]) {
            refillAmount *= 20;
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = tokens[i];

            uint256 currentAmount = token.balanceOf(_msgSender());
            if (currentAmount < refillAmount) {
                token.safeTransfer(_msgSender(), refillAmount.sub(currentAmount));
            }
        }
    }
}
