// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableVault - Manages ERC20 stablecoin deposits and withdrawals
/// @notice Users can deposit/withdraw tokens, and the contract owner can rebalance
/// @dev Extendable later with strategies or yield logic
contract StableVault {
    using SafeERC20 for IERC20;

    /// @notice Owner of the vault (set once at deployment)
    address public immutable vaultAdmin;

    /// @notice ERC20 stablecoin supported by the vault
    IERC20 public immutable token;

    /// @notice Total funds deposited in the vault
    uint256 public totalFunds;

    /// @notice Tracks each user’s deposits
    mapping(address => uint256) public userDeposits;

    /// @notice Emitted when a user makes a deposit
    event Funded(address indexed account, uint256 amount);

    /// @notice Emitted when a user withdraws
    event Redeemed(address indexed account, uint256 amount);

    /// @notice Emitted when the vault is rebalanced
    event Rebalance(uint256 newTotal);

    /// @dev Ensures only admin can call restricted functions
    modifier onlyAdmin() {
        require(msg.sender == vaultAdmin, "StableVault: not admin");
        _;
    }

    /// @param stableToken Address of the ERC20 token used
    constructor(address stableToken) {
        require(stableToken != address(0), "StableVault: zero token address");
        vaultAdmin = msg.sender;
        token = IERC20(stableToken);
    }

    /// @notice Deposit tokens into the vault
    /// @param amount Amount of tokens to deposit
    function fund(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be positive");

        token.safeTransferFrom(msg.sender, address(this), amount);

        userDeposits[msg.sender] += amount;
        totalFunds += amount;

        emit Funded(msg.sender, amount);
    }

    /// @notice Withdraw your deposited tokens
    /// @param amount Amount of tokens to withdraw
    function redeem(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be positive");
        uint256 deposited = userDeposits[msg.sender];
        require(deposited >= amount, "StableVault: insufficient funds");

        userDeposits[msg.sender] = deposited - amount;
        totalFunds -= amount;

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
