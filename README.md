# Defi Contracts

Library of smart contracts for Defi Dapps development

# Core Contracts

-   **BaseERC20.sol**: Base ERC20 token with mint and burn functionalities, and operator access control.
-   **BaseFarm.sol**: Basic staking pool for a given token. it only allows to stake or withdraw without generating rewards.
-   **BaseFarmDelegated.sol**: Similar to BaseFarm but with the ability of being used by another smart contract on behalf of an end user. Typically used to allow several operation within one single transaction.
-   **FarmDelegated.sol**: Farm with staking rewards and delegated access. The rewards are distributed to the farm through a RewardsDistributor
-   **AutoFarmLiquidity.sol**: Helper contract that allows to add liquidity to a pool and staking the generated LP tokens all in one transaction.
-   **Faucet.sol**: Simple faucet implementation to provide with free tokens.
-   **RewardsDistributor.sol**: Used to distribute rewards to several recipients all in one transaction.
-   **ContributionPool.sol**: Simple fund to store assets for later retrieval. Typically used by a project team to derive funds for emergency cases.

# Access

-   **AdminAccessControl.sol**: Simplified AccessControl contract with only Admin role.
-   **OperatorAccessControl.sol**: Simplified AccessControl contract with Operator and Admin roles.
-   **RewardsDistributorControl.sol**: Simplified AccessControl contract with RewardsDistributor, Operator and Admin roles.

# Governance

-   **Oracle.sol**: Oracle contract that provides data on the proce of a pair both from the liquidity pool and an external BandOracle contract.
-   **OperatorTimelock.sol**: Minimal Timelock controller with Admin access control

# Author

My name is Roberto Cano and you can find me at https://github.com/gabr1e11
