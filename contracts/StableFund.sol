// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableFund - ERC20-based deposit and withdrawal fund
/// @notice Allows users to deposit and withdraw a specific ERC20 stable token
/// @dev Admin can later implement rebalancing logic
contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Address of the admin (set once at deployment)
    address public immutable admin;

    /// @notice ERC20 stable token accepted for deposits and withdrawals
    IERC20 public immutable stableToken;

    /// @notice Total amount of tokens currently deposited
    uint256 public totalDeposits;

    /// @notice Mapping from user address to deposited token balance
    mapping(address => uint256) public balances;

    /// @notice Event emitted when tokens are deposited
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when tokens are withdrawn
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when rebalancing is triggered
    event Rebalanced(uint256 total);

    /// @dev Modifier to restrict certain functions to the admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "StableFund: caller is not admin");
        _;
    }

    /// @param token Address of the ERC20 stable token
    constructor(address token) {
        require(token != address(0), "StableFund: invalid token address");
        admin = msg.sender;
        stableToken = IERC20(token);
    }

    /// @notice Deposit tokens into the contract
    /// @param amount Number of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableFund: amount must be > 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw tokens previously deposited
    /// @param amount Number of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableFund: amount must be > 0");
        require(balances[msg.sender] >= amount, "StableFund: insufficient balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Admin-only placeholder function to trigger rebalancing logic
    function rebalance() external onlyAdmin {
        emit Rebalanced(totalDeposits);
    }
}
