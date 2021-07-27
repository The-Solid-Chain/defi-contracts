// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./OperatorAccessControl.sol";

/**
    Interface
 */
interface IRewardsDistributorControl {
    function isOperator(address account) external view returns (bool);

    function transferOperator(address newOperator) external;
}

/**
    Basic access control for a contract that defines an Admin and an Operator roles

        - Admin can transfer the Operator to a new account or add new Operator
        - Operator can perform calls to all functiones marked as onlyOperator()
 */
abstract contract RewardsDistributorControl is OperatorAccessControl {
    bytes32 public constant REWARDS_DISTRIBUTOR_ROLE = keccak256("REWARDS_DISTRIBUTOR_ROLE");

    address private _rewardsDistributor;

    // ==== CONSTRUCTOR ====
    constructor() {
        _setRoleAdmin(REWARDS_DISTRIBUTOR_ROLE, ADMIN_ROLE);

        _rewardsDistributor = _msgSender();

        _setupRole(REWARDS_DISTRIBUTOR_ROLE, _rewardsDistributor);
    }

    // ==== MODIFIERS ====
    modifier onlyRewardsDistributor() {
        require(
            hasRole(REWARDS_DISTRIBUTOR_ROLE, _msgSender()),
            "RewardsDistributorControl: sender requires permission"
        );
        _;
    }

    // ==== VIEWS ====
    function isRewardsDistributor(address account) external view returns (bool) {
        return hasRole(REWARDS_DISTRIBUTOR_ROLE, account);
    }

    // ==== MUTABLES ====
    function transferRewardsDistributor(address newRewardsDistributor) external onlyAdmin {
        require(newRewardsDistributor != address(0), "RewardsDistributorControl: zero address given for new operator");

        revokeRole(REWARDS_DISTRIBUTOR_ROLE, _rewardsDistributor);

        _rewardsDistributor = newRewardsDistributor;

        grantRole(REWARDS_DISTRIBUTOR_ROLE, newRewardsDistributor);
    }
}
