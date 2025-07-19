// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    // Admin address (immutable owner)
    address public admin;

    // ERC20 token interface for stablecoin
    IERC20 public stableToken;

    // Total value deposited in the contract
    uint256 public totalDeposits;

    // User balances mapping
    mapping(address => uint256) public balances;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rebalanced(uint256 newTotal);

    // Modifier for admin-only functions
    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied: Not admin");
        _;
    }

    // Constructor: sets admin and token address
    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        admin = msg.sender;
        stableToken = IERC20(tokenAddress);
    }

    // Deposit function for users
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit must be greater than 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    // Withdraw function for users
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Withdraw exceeds balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    // Admin-only rebalancing function (placeholder)
    function rebalance() external onlyAdmin {
        // Logic for rebalancing can be implemented here
        emit Rebalanced(totalDeposits);
    }
}
