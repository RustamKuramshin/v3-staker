// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@openzeppelin/contracts/utils/Address.sol';

library TransferHelperExtended {
    using Address for address;

    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.isContract(), 'TransferHelperExtended::safeTransferFrom: call to non-contract');
        TransferHelper.safeTransferFrom(token, from, to, value);
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        require(token.isContract(), 'TransferHelperExtended::safeTransfer: call to non-contract');
        TransferHelper.safeTransfer(token, to, value);
    }

    /// @notice Safely approves a spender to spend a specific amount of tokens on behalf of the caller
    /// @param token The contract address of the token to be approved
    /// @param spender The address which will be approved to spend the tokens
    /// @param value The amount of tokens to approve
    function safeApprove(
        address token,
        address spender,
        uint256 value
    ) internal {
        require(token.isContract(), 'TransferHelperExtended::safeApprove: call to non-contract');

        // Approve the spender
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSignature("approve(address,uint256)", spender, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelperExtended::safeApprove: approve failed');
    }

    /// @notice Safely checks if the sender has enough balance before transferring tokens
    /// @param token The contract address of the token to be checked
    /// @param from The address whose balance will be checked
    /// @param value The amount to be transferred
    function safeCheckAndTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.isContract(), 'TransferHelperExtended::safeCheckAndTransferFrom: call to non-contract');

        // Check the balance of the sender
        (bool success, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", from)
        );
        require(success && data.length >= 32, 'TransferHelperExtended::safeCheckAndTransferFrom: balance check failed');

        uint256 balance = abi.decode(data, (uint256));
        require(balance >= value, 'TransferHelperExtended::safeCheckAndTransferFrom: insufficient balance');

        // Perform the transfer
        TransferHelper.safeTransferFrom(token, from, to, value);
    }
}
