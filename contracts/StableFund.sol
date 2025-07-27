// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableFund - A minimal ERC20-based deposit and withdrawal fund
contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Admin address (immutable after deployment)
    address public immutable admin;

    /// @notice ERC20 stable token accepted by the fund
    IERC20 public immutable stableToken;

    /// @notice Total amount of tokens deposited
    uint256 public totalDeposits;

    /// @notice Mapping of user address to their deposit balance
    mapping(address => uint256) public balances;

    /// @notice Emitted when a user deposits tokens
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws tokens
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Emitted when the admin triggers rebalancing
    event Rebalanced(uint256 updatedTotalDeposits);

    /// @dev Ensures only the admin can call the function
    modifier onlyAdmin() {
        require(msg.sender == admin, "StableFund: caller is not admin");
        _;
    }

    /// @notice Initializes the contract with the stable token address and sets admin
    /// @param token Address of the ERC20 stable token
    constructor(address token) {
        require(token != address(0), "StableFund: token address cannot be zero");
        admin = msg.sender;
        stableToken = IERC20(token);
    }

    /// @notice Allows a user to deposit tokens into the fund
    /// @param amount Amount of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableFund: deposit must be greater than 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Allows a user to withdraw their deposited tokens
    /// @param amount Amount of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableFund: withdrawal must be greater than 0");
        require(balances[msg.sender] >= amount, "StableFund: insufficient balance");

        balances[msg.sender] -= amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Admin-only function to trigger rebalancing (no logic yet)
    function rebalance() external onlyAdmin {
        emit Rebalanced(totalDeposits);
    }
}
