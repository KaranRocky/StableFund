// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StableFund - A basic ERC20 token fund for deposits and withdrawals
/// @author -
contract StableFund {
    using SafeERC20 for IERC20;

    /// @notice Admin address set during deployment (immutable)
    address public immutable admin;

    /// @notice ERC20 stable token used in the contract
    IERC20 public immutable stableToken;

    /// @notice Tracks total deposited tokens
    uint256 public totalDeposits;

    /// @notice Maps user address to deposited token balance
    mapping(address => uint256) public balances;

    /// @notice Emitted when a user deposits tokens
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws tokens
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice Emitted when rebalancing is triggered
    event Rebalanced(uint256 updatedTotalDeposits);

    /// @dev Restricts function access to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "StableFund: caller is not the admin");
        _;
    }

    /// @param _token Address of the ERC20 token used as the stable token
    constructor(address _token) {
        require(_token != address(0), "StableFund: token address is zero");
        admin = msg.sender;
        stableToken = IERC20(_token);
    }

    /// @notice Allows users to deposit tokens into the fund
    /// @param _amount Amount of tokens to deposit
    function deposit(uint256 _amount) external {
        require(_amount > 0, "StableFund: deposit must be > 0");

        stableToken.safeTransferFrom(msg.sender, address(this), _amount);

        balances[msg.sender] += _amount;
        totalDeposits += _amount;

        emit Deposited(msg.sender, _amount);
    }

    /// @notice Allows users to withdraw their deposited tokens
    /// @param _amount Amount of tokens to withdraw
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "StableFund: withdrawal must be > 0");
        require(balances[msg.sender] >= _amount, "StableFund: insufficient balance");

        balances[msg.sender] -= _amount;
        totalDeposits -= _amount;

        stableToken.safeTransfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    /// @notice Admin-only function to trigger rebalancing logic (placeholder)
    function rebalance() external onlyAdmin {
        // Future logic for rebalancing can be added here
        emit Rebalanced(totalDeposits);
    }
}
