// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Timelock contract for all operations managed by the Operator account
 */
import "@openzeppelin/contracts/governance/TimelockController.sol";

import "../access/AdminAccessControl.sol";

contract OperatorTimelock is TimelockController, AdminAccessControlHelper {
    constructor(uint256 minDelay, address[] memory admins)
        TimelockController(minDelay, admins, admins)
        AdminAccessControlHelper(TIMELOCK_ADMIN_ROLE, _msgSender())
    {}
}
