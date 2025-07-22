// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    // Admin address, set once at deployment
    address public immutable admin;

    // Stable ERC20 token used in the fund
    IERC20 public immutable stableToken;

    // Total tokens deposited in the contract
    uint256 public totalDeposits;

    // Mapping to track individual user balances
    mapping(address => uint256) public balances;

    // Events
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rebalanced(uint256 newTotalDeposits);

    // Modifier to restrict function to admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    /// @notice Contract constructor
    /// @param token Address of the ERC20 stable token
    constructor(address token) {
        require(token != address(0), "Token address cannot be zero");
        admin = msg.sender;
        stableToken = IERC20(token);
    }

    /// @notice Deposit tokens into the fund
    /// @param amount Amount to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw tokens from the fund
    /// @param amount Amount to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(balances[msg.sender] >= amount, "Not enough balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Admin-only function to trigger rebalancing logic
    function rebalance() external onlyAdmin {
        // Future implementation
        emit Rebalanced(totalDeposits);
    }
}
