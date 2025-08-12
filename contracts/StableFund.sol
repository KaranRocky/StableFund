// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableVault - Deposit and withdrawal manager for a stable ERC20 token
/// @notice Users can deposit and withdraw a pre-defined stablecoin
/// @dev Owner can later add investment or rebalancing logic
contract StableVault {
    using SafeERC20 for IERC20;

    /// @notice Address of the contract owner (set during deployment)
    address public immutable vaultOwner;

    /// @notice The stablecoin token accepted by this vault
    IERC20 public immutable stablecoin;

    /// @notice Tracks total token holdings in the vault
    uint256 public totalHoldings;

    /// @notice Stores each user's deposited amount
    mapping(address => uint256) public deposits;

    /// @notice Emitted when tokens are added to the vault
    event TokensDeposited(address indexed depositor, uint256 amount);

    /// @notice Emitted when tokens are removed from the vault
    event TokensWithdrawn(address indexed recipient, uint256 amount);

    /// @notice Emitted when rebalancing is executed
    event VaultRebalanced(uint256 holdingsAfterRebalance);

    /// @dev Restricts a function so only the owner can call it
    modifier onlyVaultOwner() {
        require(msg.sender == vaultOwner, "StableVault: not authorized");
        _;
    }

    /// @param tokenAddress The ERC20 stablecoin's contract address
    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "StableVault: zero address");
        vaultOwner = msg.sender;
        stablecoin = IERC20(tokenAddress);
    }

    /// @notice Allows a user to deposit tokens into the vault
    /// @param amount The number of tokens to deposit
    function addFunds(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be positive");

        stablecoin.safeTransferFrom(msg.sender, address(this), amount);

        deposits[msg.sender] += amount;
        totalHoldings += amount;

        emit TokensDeposited(msg.sender, amount);
    }

    /// @notice Allows a user to withdraw previously deposited tokens
    /// @param amount The number of tokens to withdraw
    function removeFunds(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be positive");
        uint256 userDeposit = deposits[msg.sender];
        require(userDeposit >= amount, "StableVault: insufficient balance");

        deposits[msg.sender] = userDeposit - amount;
        totalHoldings -= amount;

        stablecoin.safeTransfer(msg.sender, amount);

        emit TokensWithdrawn(msg.sender, amount);
    }

    /// @notice Triggers a rebalancing operation (owner only)
    function rebalanceVault() external onlyVaultOwner {
        emit VaultRebalanced(totalHoldings);
    }
}        totalFunds -= amount;

        token.safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Placeholder function for admin-only rebalancing
    function triggerRebalance() external onlyOwner {
        emit RebalanceTriggered(totalFunds);
    }
}
