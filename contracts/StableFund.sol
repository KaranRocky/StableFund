// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableReserve - A secure ERC20-based deposit and withdrawal vault
/// @notice Enables users to deposit and withdraw a specific stablecoin
/// @dev Admin can extend this contract to add investment/rebalancing strategies
contract StableReserve {
    using SafeERC20 for IERC20;

    /// @dev Address of the contract owner (immutable after deployment)
    address public immutable owner;

    /// @dev ERC20 stablecoin accepted for deposits and withdrawals
    IERC20 public immutable token;

    /// @dev Total amount of tokens deposited into the vault
    uint256 public totalFunds;

    /// @dev Mapping of user wallet → deposited balance
    mapping(address => uint256) public userBalances;

    /// @notice Emitted when a deposit occurs
    event Deposit(address indexed account, uint256 amount);

    /// @notice Emitted when a withdrawal occurs
    event Withdrawal(address indexed account, uint256 amount);

    /// @notice Emitted when rebalancing is initiated
    event RebalanceTriggered(uint256 currentTotal);

    /// @dev Restricts function access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "StableReserve: caller not owner");
        _;
    }

    /// @param tokenAddress The ERC20 stablecoin contract address
    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "StableReserve: invalid token address");
        owner = msg.sender;
        token = IERC20(tokenAddress);
    }

    /// @notice Deposit stablecoins into the vault
    /// @param amount The number of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableReserve: amount must be greater than zero");

        token.safeTransferFrom(msg.sender, address(this), amount);

        userBalances[msg.sender] += amount;
        totalFunds += amount;

        emit Deposit(msg.sender, amount);
    }

    /// @notice Withdraw previously deposited stablecoins
    /// @param amount The number of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableReserve: amount must be greater than zero");
        uint256 balance = userBalances[msg.sender];
        require(balance >= amount, "StableReserve: insufficient funds");

        userBalances[msg.sender] = balance - amount;
        totalFunds -= amount;

        token.safeTransfer(msg.sender, amount);

        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Placeholder function for admin-only rebalancing
    function triggerRebalance() external onlyOwner {
        emit RebalanceTriggered(totalFunds);
    }
}
