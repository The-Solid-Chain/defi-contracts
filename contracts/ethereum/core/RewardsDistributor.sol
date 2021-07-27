// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Contract used to inject the initial reward to the staking pool
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../access/OperatorAccessControl.sol";

/**
    Interfaces
 */
interface IRewardsDistributor {
    function distribute() external;
}

abstract contract IRewardsDistributorRecipient {
    function notifyRewardAmount(uint256 reward) external virtual;
}

/**
    Helper contract to distribute rewards funds to different contracts in one single transaction
 */
contract RewardsDistributor is OperatorAccessControl {
    using SafeMath for uint256;

    // ====== STATE ======
    IERC20 public _rewardToken;
    IRewardsDistributorRecipient[] public _rewardRecipients;

    // ====== CONSTRUCTOR ======
    constructor(IERC20 rewardToken, IRewardsDistributorRecipient[] memory rewardRecipients) {
        require(rewardRecipients.length != 0, "RewardsDistributor: recipients list is empty");

        _rewardToken = rewardToken;
        _rewardRecipients = rewardRecipients;
    }

    function getTotalRewards() external view returns (uint256) {
        return _rewardToken.balanceOf(address(this));
    }

    // ====== MUTABLES ======
    function distribute() public onlyOperator {
        uint256 totalRewards = _rewardToken.balanceOf(address(this));
        uint256 amountPerRecipient = totalRewards.div(_rewardRecipients.length);

        for (uint256 i = 0; i < _rewardRecipients.length; i++) {
            _rewardToken.transfer(address(_rewardRecipients[i]), amountPerRecipient);
            _rewardRecipients[i].notifyRewardAmount(amountPerRecipient);

            emit RewardDistributed(address(_rewardRecipients[i]), amountPerRecipient);
        }
    }

    // ====== EVENTS ======
    event RewardDistributed(address recipient, uint256 amount);
}
