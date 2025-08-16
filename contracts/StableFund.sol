// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableBank - A vault for deposits and withdrawals of a stable ERC20 token
/// @notice Users can deposit and withdraw the chosen stablecoin
/// @dev The owner may extend this with rebalancing or yield strategies
contract StableBank {
    using SafeERC20 for IERC20;

    /// @notice The account designated as contract owner
    address public immutable owner;

    /// @notice The ERC20 stablecoin accepted by this contract
    IERC20 public immutable stable;

    /// @notice Total tokens currently managed by the vault
    uint256 public totalBalance;

    /// @notice Mapping of user → amount of stable tokens deposited
    mapping(address => uint256) public balances;

    /// @notice Emitted when a deposit occurs
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a withdrawal occurs
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Emitted when rebalancing is triggered
    event Rebalanced(uint256 newTotal);

    /// @dev Restricts function access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "StableBank: caller is not owner");
        _;
    }

    /// @param token Address of the ERC20 stablecoin to use
    constructor(address token) {
        require(token != address(0), "StableBank: invalid token");
        owner = msg.sender;
        stable = IERC20(token);
    }

    /// @notice Deposit stablecoins into the vault
    /// @param amount Amount of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableBank: deposit amount must be > 0");

        stable.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalBalance += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw your deposited stablecoins
    /// @param amount Amount of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableBank: withdraw amount must be > 0");
        uint256 userBal = balances[msg.sender];
        require(userBal >= amount, "StableBank: insufficient balance");

        balances[msg.sender] = userBal - amount;
        totalBalance -= amount;

        stable.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Owner-only function to initiate rebalancing
    function rebalance() external onlyOwner {
        emit Rebalanced(totalBalance);
    }
}        totalHoldings -= amount;

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
