// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
    Base contract for the tokens in the system

    All tokens are burnable and have an operator
 */
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "../access/OperatorAccessControl.sol";

/**
    Interface
 */
interface IBaseERC20 {
    function mint(address recipient, uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;
}

/**
    Base implementation of a ERC20 burnable token with access control for an Operator
 */
contract BaseERC20 is ERC20Burnable, OperatorAccessControl {
    /* ========== CONSTRUCTOR ========== */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /* ========== MUTABLES ========== */
    function mint(address recipient_, uint256 amount_) external onlyOperator {
        _mint(recipient_, amount_);
    }

    function burn(uint256 amount) public override onlyOperator {
        super.burn(amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyOperator {
        super.burnFrom(account, amount);
    }
}
