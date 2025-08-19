// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableVault - A vault for ERC20 stablecoin deposits and withdrawals
/// @notice Users can deposit and withdraw tokens, owner can trigger rebalancing
/// @dev Logic can be extended later to include strategies
contract StableVault {
    using SafeERC20 for IERC20;

    /// @notice Address of the contract owner (set at deployment)
    address public immutable owner;

    /// @notice ERC20 stablecoin accepted by this vault
    IERC20 public immutable stableToken;

    /// @notice Total stablecoins held in the vault
    uint256 public totalDeposits;

    /// @notice Mapping from user → deposited balance
    mapping(address => uint256) public balances;

    /// @notice Event emitted when a user deposits
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when a user withdraws
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when rebalancing is triggered
    event Rebalanced(uint256 total);

    /// @dev Restrict function calls to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "StableVault: caller is not owner");
        _;
    }

    /// @param token Address of the ERC20 stablecoin
    constructor(address token) {
        require(token != address(0), "StableVault: invalid token address");
        owner = msg.sender;
        stableToken = IERC20(token);
    }

    /// @notice Deposit stablecoins into the vault
    /// @param amount Number of tokens to deposit
    function deposit(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be > 0");

        stableToken.safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
        totalDeposits += amount;

        emit Deposited(msg.sender, amount);
    }

    /// @notice Withdraw your deposited stablecoins
    /// @param amount Number of tokens to withdraw
    function withdraw(uint256 amount) external {
        require(amount > 0, "StableVault: amount must be > 0");
        uint256 bal = balances[msg.sender];
        require(bal >= amount, "StableVault: insufficient balance");

        balances[msg.sender] = bal - amount;
        totalDeposits -= amount;

        stableToken.safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Trigger rebalancing (owner only)
    function rebalance() external onlyOwner {
        emit Rebalanced(totalDeposits);
    }
}
