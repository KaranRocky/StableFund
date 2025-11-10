// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/// @title ReserveVault - Stores ERC20 tokens with deposit/withdraw functionality
/// @notice Users can add/remove funds, while the manager can initiate rebalancing
/// @dev Designed to be extended later for yield strategies
contract ReserveVault {
    using SafeERC20 for IERC20;

    /// @notice Address of the vault manager
    address public immutable manager;

    /// @notice ERC20 token handled by the vault
    IERC20 public immutable reserveToken;

    /// @notice Aggregate balance tracked in the vault
    uint256 public vaultBalance;

    /// @notice User balances mapping
    mapping(address => uint256) public deposits;

    /// @notice Emitted when tokens are added to the vault
    event Deposit(address indexed account, uint256 amount);

    /// @notice Emitted when tokens are withdrawn
    event Withdrawal(address indexed account, uint256 amount);

    /// @notice Emitted when vault undergoes rebalancing
    event VaultRebalanced(uint256 currentTotal);

    /// @dev Restricts to only manager
    modifier onlyManager() {
        require(msg.sender == manager, "ReserveVault: not manager");
        _;
    }

    /// @param token ERC20 token address supported
    constructor(address token) {
        require(token != address(0), "ReserveVault: invalid token");
        manager = msg.sender;
        reserveToken = IERC20(token);
    }

    /// @notice Add tokens into vault
    /// @param amount Amount of tokens to deposit
    function addFunds(uint256 amount) external {
        require(amount > 0, "ReserveVault: amount must be > 0");

        reserveToken.safeTransferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        vaultBalance += amount;

        emit Deposit(msg.sender, amount);
    }

    /// @notice Remove tokens from vault
    /// @param amount Amount of tokens to withdraw
    function removeFunds(uint256 amount) external {
        require(amount > 0, "ReserveVault: amount must be > 0");
        uint256 userFunds = deposits[msg.sender];
        require(userFunds >= amount, "ReserveVault: insufficient funds");

        deposits[msg.sender] = userFunds - amount;
        vaultBalance -= amount;

        reserveToken.safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Manager-only rebalance trigger
    function rebalanceVault() external onlyManager {
        emit VaultRebalanced(vaultBalance);
    }
}        totalAssets -= amount;

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
