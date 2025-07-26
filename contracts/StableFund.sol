// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableFund - Basic ERC20 deposit and withdrawal fund
contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Admin address (set at deployment)
    address public immutable admin;

    /// @notice ERC20 stable token accepted by this fund
    IERC20 public immutable stableToken;

    /// @notice Total tokens deposited in the fund
    uint256 public totalDeposits;

    /// @notice Mapping of user address to balance
    mapping(address => uint256) public balances;

    /// @notice Event emitted when a deposit occurs
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when a withdrawal occurs
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when rebalancing is triggered
    event Rebalanced(uint256 newTotalDeposits);

    /// @dev Restrict function to only admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "StableFund: caller is not admin");
        _;
    }

    /// @param token ERC20 token address used as stable token
    constructor(address token) {
        require(token != address(0), "StableFund: token address cannot be zero");
        admin = msg.sender;
        stableToken = IERC20(token);
    }

    /// @notice Deposit tokens into the fund
    /// @param amount Amount of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableFund: deposit amount must be greater than 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw tokens from the fund
    /// @param amount Amount of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableFund: withdraw amount must be greater than 0");
        require(balances[msg.sender] >= amount, "StableFund: insufficient balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Admin-only: trigger rebalancing (placeholder)
    function rebalance() external onlyAdmin {
        // Placeholder for rebalancing strategy
        emit Rebalanced(totalDeposits);
    }
}
