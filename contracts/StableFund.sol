// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StableFund {
    using SafeERC20 for IERC20;

    // Immutable admin address (set once at deployment)
    address public immutable admin;

    // ERC20 stable token used for deposits and withdrawals
    IERC20 public stableToken;

    // Tracks total token deposits in the contract
    uint256 public totalDeposits;

    // Maps user addresses to their deposit balances
    mapping(address => uint256) public balances;

    // Events for logging key contract operations
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Rebalanced(uint256 newTotalDeposits);

    // Modifier to restrict function access to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied: Only admin");
        _;
    }

    /// @notice Constructor to initialize the stable token and admin
    /// @param _tokenAddress Address of the ERC20 token to be used
    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        admin = msg.sender;
        stableToken = IERC20(_tokenAddress);
    }

    /// @notice Allows users to deposit tokens into the fund
    /// @param _amount Amount of tokens to deposit
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Deposit amount must be greater than zero");

        stableToken.safeTransferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit Deposited(msg.sender, _amount);
    }

    /// @notice Allows users to withdraw their tokens from the fund
    /// @param _amount Amount of tokens to withdraw
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Withdraw amount must be greater than zero");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        stableToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice Admin function to initiate rebalancing (logic TBD)
    function rebalance() external onlyAdmin {
        // Rebalancing strategy will be implemented here
        emit Rebalanced(totalDeposits);
    }
}
