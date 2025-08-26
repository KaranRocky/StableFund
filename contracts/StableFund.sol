// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title TreasuryVault - Manages ERC20 stablecoin deposits and withdrawals
/// @notice Users can deposit/withdraw funds, while the contract governor can rebalance
/// @dev Can be extended in the future with strategies or yield farming logic
contract TreasuryVault {
    using SafeERC20 for IERC20;

    /// @notice Address of the governor (admin) of the vault
    address public immutable governor;

    /// @notice ERC20 token supported by this vault
    IERC20 public immutable asset;

    /// @notice Total funds locked inside the vault
    uint256 public totalAssets;

    /// @notice Records deposits of each user
    mapping(address => uint256) public balances;

    /// @notice Event emitted when funds are deposited
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when funds are withdrawn
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when the vault is rebalanced
    event Rebalanced(uint256 updatedTotal);

    /// @dev Restricts function access to only governor
    modifier onlyGovernor() {
        require(msg.sender == governor, "TreasuryVault: caller not governor");
        _;
    }

    /// @param token Address of ERC20 token used in this vault
    constructor(address token) {
        require(token != address(0), "TreasuryVault: invalid token address");
        governor = msg.sender;
        asset = IERC20(token);
    }

    /// @notice Deposit tokens into the vault
    /// @param amount Amount to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "TreasuryVault: deposit must be > 0");

        asset.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalAssets += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw user’s funds from the vault
    /// @param amount Amount to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "TreasuryVault: withdrawal must be > 0");
        uint256 userBal = balances[msg.sender];
        require(userBal >= amount, "TreasuryVault: insufficient balance");

        balances[msg.sender] = userBal - amount;
        totalAssets -= amount;

        asset.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Trigger vault rebalancing (only governor can call)
    function rebalance() external onlyGovernor {
        emit Rebalanced(totalAssets);
    }
}        vaultBalance -= amount;

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
