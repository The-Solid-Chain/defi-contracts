// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Generic staking pool with delegated access. LP tokens staked here will generate ANT Token rewards
    to the holder
 */
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../access/RewardsDistributorControl.sol";

import "../core/RewardsDistributor.sol";

import "../utils/StartTimeLock.sol";

import "./BaseFarmDelegated.sol";

contract FarmDelegated is BaseFarmDelegated, RewardsDistributorControl, IRewardsDistributorRecipient, StartTimeLock {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public rewardToken;
    uint256 public DURATION = 365 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    /* ========== CONSTRUCTOR ========== */
    constructor(
        IERC20 rewardToken_,
        IERC20 stakingToken_,
        uint256 startTime_
    ) BaseFarmDelegated(stakingToken_) IRewardsDistributorRecipient() StartTimeLock(startTime_) {
        rewardToken = rewardToken_;
    }

    /* ========== MODIFIERS ========== */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== VIEWS ========== */
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(
                rewards[account]
            );
    }

    /* ========== MUTABLES ========== */

    /**
        Updates rewards for origin account and caller parent for delegated staking

        This method can only be called by the contract owner

        @param amount Amount of LP tokens to stake
        @param origin_account Account that originally owned the LP tokens and on which
                              behalf the tokens are staked
    */
    function stake(uint256 amount, address origin_account)
        public
        override
        updateReward(origin_account)
        checkStartTime
        onlyOperator
    {
        require(amount > 0, "BaseStakingPool: Cannot stake 0");
        super.stake(amount, origin_account);
        emit Staked(origin_account, amount);
    }

    /**
        Delegated withdrawing on behalf of an origin account. The caller will receive the
        LP tokens to be withdrawn

        This method can only be called by the contract owner
        
        @param amount Amount of LP tokens to be withdrawn
        @param origin_account Account on which behalf the LP tokens are withdrawn
    */
    function withdraw(uint256 amount, address origin_account)
        public
        override
        updateReward(origin_account)
        checkStartTime
        onlyOperator
    {
        require(amount > 0, "BaseStakingPool: Cannot withdraw 0");
        super.withdraw(amount, origin_account);

        emit Withdrawn(origin_account, amount);
    }

    /**
        Delegated exiting on behalf of an origin account. It calls the parent to perform
        a delegated exit and then get the rewards for the origin account

        This method can only be called by the contract owner
        
        @param origin_account Account on which behalf the LP tokens are withdrawn

        @return The amount of LP tokens withdrawn
    */
    function exit(address origin_account) public override onlyOperator returns (uint256) {
        uint256 balance = super.exit(origin_account);
        getReward(origin_account);
        return balance;
    }

    /**
        Gets the rewards for the origin account and sends the reward tokens to it

        This method can only be called by the contract owner
        
        @param origin_account Account on which behalf the LP tokens are withdrawn
    */
    function getReward(address origin_account) public updateReward(origin_account) checkStartTime onlyOperator {
        uint256 reward = earned(origin_account);
        if (reward > 0) {
            rewards[origin_account] = 0;
            rewardToken.safeTransfer(origin_account, reward);
            emit RewardPaid(origin_account, reward);
        }
    }

    /**
        Gets the rewards for the caller account and sends the reward tokens to it

        This method can only be called by the contract owner
    */
    function getMyReward() public updateReward(_msgSender()) checkStartTime {
        uint256 reward = earned(_msgSender());
        if (reward > 0) {
            rewards[_msgSender()] = 0;
            rewardToken.safeTransfer(_msgSender(), reward);
            emit RewardPaid(_msgSender(), reward);
        }
    }

    /**
        Called by the distribution script to allocate an amount of reward tokens
        to the pool, to be rewarded to the pool stake holders when calling getReward()

        @dev Can only be called by the reward distributor set through IRewardDistributionRecipient::setRewardDistributor

        @param reward  Amount of reward tokens allocated to the pool
     */
    function notifyRewardAmount(uint256 reward) external override onlyRewardsDistributor updateReward(address(0)) {
        if (block.timestamp > startTime) {
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(DURATION);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(DURATION);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(reward);
        } else {
            rewardRate = reward.div(DURATION);
            lastUpdateTime = startTime;
            periodFinish = startTime.add(DURATION);
            emit RewardAdded(reward);
        }
    }
}
