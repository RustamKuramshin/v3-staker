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

    /// @notice Calculates the current value of the position in token0 and token1
    /// @param pool The address of the Uniswap V3 pool
    /// @param liquidity The amount of liquidity in the position
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @return amount0 The estimated amount of token0 in the position
    /// @return amount1 The estimated amount of token1 in the position
    function getPositionValue(
        IUniswapV3Pool pool,
        uint128 liquidity,
        int24 tickLower,
        int24 tickUpper
    ) internal view returns (uint256 amount0, uint256 amount1) {
        // Get the current tick and sqrtPriceX96 from the pool
        (uint160 sqrtPriceX96, int24 currentTick, , , , , ) = pool.slot0();

        // Calculate the amounts of token0 and token1 based on the liquidity and ticks
        if (currentTick < tickLower) {
            // If the current tick is below the position range, all liquidity is in token0
            amount0 = LiquidityAmounts.getAmount0ForLiquidity(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
        } else if (currentTick > tickUpper) {
            // If the current tick is above the position range, all liquidity is in token1
            amount1 = LiquidityAmounts.getAmount1ForLiquidity(
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                sqrtPriceX96,
                liquidity
            );
        } else {
            // If the current tick is within the position range, calculate both token0 and token1
            amount0 = LiquidityAmounts.getAmount0ForLiquidity(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(currentTick),
                liquidity
            );
            amount1 = LiquidityAmounts.getAmount1ForLiquidity(
                TickMath.getSqrtRatioAtTick(currentTick),
                TickMath.getSqrtRatioAtTick(tickUpper),
                sqrtPriceX96,
                liquidity
            );
        }
    }
}
