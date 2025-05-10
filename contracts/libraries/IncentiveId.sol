// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/IUniswapV3Staker.sol';

library IncentiveId {
    /// @notice Calculate the key for a staking incentive
    /// @param key The components used to compute the incentive identifier
    /// @return incentiveId The identifier for the incentive
    function compute(IUniswapV3Staker.IncentiveKey memory key) internal pure returns (bytes32 incentiveId) {
        return keccak256(abi.encode(key));
    }

    /// @notice Decode the incentive identifier back into its components
    /// @param incentiveId The identifier for the incentive
    /// @return key The components used to compute the incentive identifier
    function decode(bytes32 incentiveId) internal pure returns (IUniswapV3Staker.IncentiveKey memory key) {
        return abi.decode(abi.encodePacked(incentiveId), (IUniswapV3Staker.IncentiveKey));
    }
}
