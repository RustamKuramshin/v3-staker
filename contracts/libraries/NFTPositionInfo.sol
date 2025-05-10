// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';

/// @notice Encapsulates the logic for getting info about a NFT token ID
library NFTPositionInfo {
    /// @param factory The address of the Uniswap V3 Factory used in computing the pool address
    /// @param nonfungiblePositionManager The address of the nonfungible position manager to query
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @return pool The address of the Uniswap V3 pool
    /// @return tickLower The lower tick of the Uniswap V3 position
    /// @return tickUpper The upper tick of the Uniswap V3 position
    /// @return liquidity The amount of liquidity staked
    function getPositionInfo(
        IUniswapV3Factory factory,
        INonfungiblePositionManager nonfungiblePositionManager,
        uint256 tokenId
    )
        internal
        view
        returns (
            IUniswapV3Pool pool,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity
        )
    {
        address token0;
        address token1;
        uint24 fee;
        (, , token0, token1, fee, tickLower, tickUpper, liquidity, , , , ) = nonfungiblePositionManager.positions(
            tokenId
        );

        pool = IUniswapV3Pool(
            PoolAddress.computeAddress(
                address(factory),
                PoolAddress.PoolKey({token0: token0, token1: token1, fee: fee})
            )
        );
    }

    /// @notice Returns token addresses and balances for a given NFT position
    /// @param nonfungiblePositionManager The address of the nonfungible position manager to query
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @return token0 The address of the first token in the pair
    /// @return token1 The address of the second token in the pair
    /// @return amount0 The amount of token0 in the position
    /// @return amount1 The amount of token1 in the position
    function getTokenBalances(
        INonfungiblePositionManager nonfungiblePositionManager,
        uint256 tokenId
    )
        internal
        view
        returns (
            address token0,
            address token1,
            uint256 amount0,
            uint256 amount1
        )
    {
        (, , token0, token1, , , , , , , , ) = nonfungiblePositionManager.positions(tokenId);

        (amount0, amount1) = nonfungiblePositionManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this), // Use the current contract as the recipient
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
    }
}
