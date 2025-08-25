// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title ReserveVault - Handles deposits and withdrawals of ERC20 stablecoins
/// @notice Users can add/remove funds, while the contract manager can rebalance
/// @dev Future updates may include strategies for yield optimization
contract ReserveVault {
    using SafeERC20 for IERC20;

    /// @notice Manager (owner) of the vault set during deployment
    address public immutable manager;

    /// @notice ERC20 stablecoin accepted by the vault
    IERC20 public immutable reserveToken;

    /// @notice Tracks overall deposits in the vault
    uint256 public vaultBalance;

    /// @notice Mapping of user → deposited amount
    mapping(address => uint256) public holdings;

    /// @notice Event emitted on deposit
    event Deposit(address indexed depositor, uint256 value);

    /// @notice Event emitted on withdrawal
    event Withdrawal(address indexed withdrawer, uint256 value);

    /// @notice Event emitted when vault is rebalanced
    event VaultRebalanced(uint256 currentBalance);

    /// @dev Restricts access to manager-only functions
    modifier onlyManager() {
        require(msg.sender == manager, "ReserveVault: caller not manager");
        _;
    }

    /// @param token Address of the ERC20 stablecoin used in the vault
    constructor(address token) {
        require(token != address(0), "ReserveVault: invalid token address");
        manager = msg.sender;
        reserveToken = IERC20(token);
    }

    /// @notice Deposit stablecoins into the vault
    /// @param amount Number of tokens to deposit
    function addFunds(uint256 amount) external {
        require(amount > 0, "ReserveVault: deposit must be > 0");

        reserveToken.safeTransferFrom(msg.sender, address(this), amount);

        holdings[msg.sender] += amount;
        vaultBalance += amount;

        emit Deposit(msg.sender, amount);
    }

    /// @notice Withdraw previously deposited stablecoins
    /// @param amount Number of tokens to withdraw
    function removeFunds(uint256 amount) external {
        require(amount > 0, "ReserveVault: withdrawal must be > 0");
        uint256 userBalance = holdings[msg.sender];
        require(userBalance >= amount, "ReserveVault: insufficient balance");

        holdings[msg.sender] = userBalance - amount;
        vaultBalance -= amount;

        reserveToken.safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Manager-only rebalance trigger
    function rebalanceVault() external onlyManager {
        emit VaultRebalanced(vaultBalance);
    }
}        totalFunds -= amount;

        token.safeTransfer(msg.sender, amount);

        emit Redeemed(msg.sender, amount);
    }

    /// @notice Trigger vault rebalancing (admin only)
    function triggerRebalance() external onlyAdmin {
        emit Rebalance(totalFunds);
    }
}        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Trigger rebalancing (owner only)
    function rebalance() external onlyOwner {
        emit Rebalanced(totalDeposits);
    }
}
