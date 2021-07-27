// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Generic LP Token Pool
*/

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
    Interface
*/
interface IBaseFarm {
    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function exit() external returns (uint256);
}

/**
    Contract
 */
contract BaseFarm is Context {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */
    constructor(IERC20 token_) {
        token = token_;
    }

    /* ========== VIEWS ========== */

    /**
        Returns the total supply of LP tokens staked in the contract
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
        Returns the current balance of the given account

        @param account Account for which the balance is requested
    */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /* ========== MUTABLES ========== */

    /**
        Staking for the message sender. The caller holds the
        LP tokens to be staked

        This method can only be called by the contract operator

        @param amount Amount of LP tokens to stake
    */
    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].add(amount);

        token.safeTransferFrom(_msgSender(), address(this), amount);
    }

    /**
        Withdrawal for the message sender The caller will receive the
        LP tokens to be withdrawn

        This method can only be called by the contract operator
        
        @param amount Amount of LP tokens to be withdrawn
    */
    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount);

        token.safeTransfer(_msgSender(), amount);
    }

    /**
        Exiting for the message sender. It performs a withdraw of all
        the staked tokens. The caller will receive the LP tokens to be withdrawn

        This method can only be called by the contract operator
        
        @return The amount of LP tokens withdrawn
    */
    function exit() public virtual returns (uint256) {
        uint256 balance = balanceOf(_msgSender());
        withdraw(balance);
        return balance;
    }
}
