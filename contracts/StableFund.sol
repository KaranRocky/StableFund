// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    // Immutable admin address (set at deployment)
    address public immutable admin;

    // ERC20 stablecoin token
    IERC20 public stableToken;

    // Total deposited tokens in the contract
    uint256 public totalDeposits;

    // Tracks user balances
    mapping(address => uint256) public balances;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rebalanced(uint256 totalDeposits);

    // Restricts function access to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // Constructor to initialize stable token and admin
    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        admin = msg.sender;
        stableToken = IERC20(_tokenAddress);
    }

    // Allows users to deposit tokens into the fund
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    // Allows users to withdraw their deposited tokens
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    // Admin function to trigger rebalancing (placeholder)
    function rebalance() external onlyAdmin {
        // Rebalancing strategy to be implemented later
        emit Rebalanced(totalDeposits);
    }
}
