// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Generic LP Token Pool with delegated access

    It allows for delegated staking/withdraw on behalf of an origin account. The LP
    tokens transfers are always done between the caller and this contract, but the
    balances of the tokens are shown for the origin account. This allows for a helper
    contract to add liquidity and stake all in one transaction
*/

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../access/OperatorAccessControl.sol";

/**
    Interface
*/
interface IBaseFarmDelegated {
    function stake(uint256 amount, address origin_account) external;

    function withdraw(uint256 amount, address origin_account) external;

    function exit(address origin_account) external returns (uint256);
}

/**
    Contract
 */
contract BaseFarmDelegated is OperatorAccessControl {
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
        Delegated staking on behalf of an origin account. The caller holds the
        LP tokens to be staked

        This method can only be called by the contract owner

        @param amount Amount of LP tokens to stake
        @param origin_account Account that originally owned the LP tokens and on which
                              behalf the tokens are staked
    */
    function stake(uint256 amount, address origin_account) public virtual onlyOperator {
        _totalSupply = _totalSupply.add(amount);
        _balances[origin_account] = _balances[origin_account].add(amount);

        token.safeTransferFrom(_msgSender(), address(this), amount);
    }

    /**
        Delegated withdrawing on behalf of an origin account. The caller will receive the
        LP tokens to be withdrawn

        This method can only be called by the contract owner
        
        @param amount Amount of LP tokens to be withdrawn
        @param origin_account Account on which behalf the LP tokens are withdrawn
    */
    function withdraw(uint256 amount, address origin_account) public virtual onlyOperator {
        _totalSupply = _totalSupply.sub(amount);
        _balances[origin_account] = _balances[origin_account].sub(amount);

        token.safeTransfer(_msgSender(), amount);
    }

    /**
        Delegated exiting on behalf of an origin account. It performs a withdraw of all
        the staked tokens. The caller will receive the LP tokens to be withdrawn

        This method can only be called by the contract owner
        
        @param origin_account Account on which behalf the LP tokens are withdrawn

        @return The amount of LP tokens withdrawn
    */
    function exit(address origin_account) public virtual onlyOperator returns (uint256) {
        uint256 balance = balanceOf(origin_account);
        withdraw(balance, origin_account);
        return balance;
    }
}
