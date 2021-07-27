// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./AdminAccessControl.sol";

/**
    Interface
 */
interface IOperatorAccessControl {
    function isOperator(address account) external view returns (bool);

    function transferOperator(address newOperator) external;

    function transferAdmin(address newAdmin) external;
}

/**
    Basic access control for a contract that defines an Admin and an Operator roles

        - Admin can transfer the Operator to a new account or add new Operator
        - Operator can perform calls to all functiones marked as onlyOperator()
 */
abstract contract OperatorAccessControl is AdminAccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    address private _operator;

    // ==== CONSTRUCTOR ====
    constructor() {
        _setRoleAdmin(OPERATOR_ROLE, ADMIN_ROLE);

        _operator = _msgSender();

        _setupRole(OPERATOR_ROLE, _operator);
    }

    // ==== MODIFIERS ====
    modifier onlyOperator() {
        require(hasRole(OPERATOR_ROLE, _msgSender()), "OperatorAccessControl: sender requires permission");
        _;
    }

    // ==== VIEWS ====
    function isOperator(address account) external view returns (bool) {
        return hasRole(OPERATOR_ROLE, account);
    }

    // ==== MUTABLES ====
    function transferOperator(address newOperator) external onlyAdmin {
        require(newOperator != address(0), "OperatorAccessControl: zero address given for new operator");

        revokeRole(OPERATOR_ROLE, _operator);

        _operator = newOperator;

        grantRole(OPERATOR_ROLE, newOperator);
    }
}
