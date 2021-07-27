// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Counts epoch periods and defines a modifier to prevent operations if the next
    epoch has not been reached yet

    @dev Calling the checkEpoch modifier will automatilly increase the epoch to the
    next period if the check succeeds
 */
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../access/OperatorAccessControl.sol";
import "./StartTimeLock.sol";

contract EpochCounter is OperatorAccessControl, StartTimeLock {
    using SafeMath for uint256;

    uint256 private _period;
    uint256 private _epoch;

    /* ========== CONSTRUCTOR ========== */

    constructor(
        uint256 period,
        uint256 startTime,
        uint256 startEpoch
    ) StartTimeLock(startTime) {
        _period = period;
        _epoch = startEpoch;
    }

    /* ========== Modifier ========== */
    modifier checkEpoch {
        require(block.timestamp >= nextEpochPoint(), "Epoch: not allowed");
        _;
        _epoch = _epoch.add(1);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function getCurrentEpoch() public view returns (uint256) {
        return _epoch;
    }

    function getPeriod() public view returns (uint256) {
        return _period;
    }

    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(_epoch.mul(_period));
    }

    /* ========== GOVERNANCE ========== */
    function setPeriod(uint256 period) external onlyOperator {
        _period = period;
    }
}
