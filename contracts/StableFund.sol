// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Address of the admin (immutable after deployment)
    address public immutable admin;

    /// @notice ERC20 stablecoin accepted for deposits
    IERC20 public immutable stableToken;

    /// @notice Total amount of tokens deposited in the contract
    uint256 public totalDeposits;

    /// @notice Mapping of user addresses to their token balances
    mapping(address => uint256) public balances;

    /// @notice Event emitted when a user makes a deposit
    event Deposited(address indexed user, uint256 amount);

    /// @notice Event emitted when a user makes a withdrawal
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Event emitted when rebalancing is triggered
    event Rebalanced(uint256 newTotalDeposits);

    /// @dev Restricts function to be called by admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied: Only admin");
        _;
    }

    /// @param _token Address of the ERC20 stable token
    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        admin = msg.sender;
        stableToken = IERC20(_token);
    }

    /// @notice Deposits `_amount` of tokens into the fund
    /// @param _amount Amount of tokens to deposit
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Deposit must be greater than 0");

        stableToken.safeTransferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit Deposited(msg.sender, _amount);
    }

    /// @notice Withdraws `_amount` of tokens from the fund
    /// @param _amount Amount of tokens to withdraw
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Withdraw must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        stableToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice Triggers rebalancing (admin-only; logic to be implemented)
    function rebalance() external onlyAdmin {
        // Placeholder for future rebalancing logic
        emit Rebalanced(totalDeposits);
    }
}
