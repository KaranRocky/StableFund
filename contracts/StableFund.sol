// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Admin address (immutable)
    address public immutable admin;

    /// @notice Stable ERC20 token used for deposits
    IERC20 public immutable stableToken;

    /// @notice Total tokens deposited in the contract
    uint256 public totalDeposits;

    /// @notice User address to balance mapping
    mapping(address => uint256) public balances;

    /// @notice Emitted when a user deposits tokens
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws tokens
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Emitted when admin triggers rebalancing
    event Rebalanced(uint256 newTotalDeposits);

    /// @notice Restrict function to admin only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied: caller is not admin");
        _;
    }

    /// @param _token Address of the ERC20 token to be used
    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        admin = msg.sender;
        stableToken = IERC20(_token);
    }

    /// @notice Deposit tokens into the fund
    /// @param _amount Amount of tokens to deposit
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Deposit must be greater than 0");

        stableToken.safeTransferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit Deposited(msg.sender, _amount);
    }

    /// @notice Withdraw tokens from the fund
    /// @param _amount Amount of tokens to withdraw
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Withdraw must be greater than 0");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        stableToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice Admin function to initiate rebalancing (to be implemented)
    function rebalance() external onlyAdmin {
        // Rebalancing logic placeholder
        emit Rebalanced(totalDeposits);
    }
}
