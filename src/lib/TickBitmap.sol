//// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./BitMath.sol";

library TickBitmap {
    function position(
        int24 tick
    ) private pure returns (int16 wordPos, uint8 bitPos) {
        wordPos = int16(tick >> 8);
        bitPos = uint8(uint24(tick & 256));
    }

    function flipTick(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing
    ) internal {
        require(tick % tickSpacing == 0);
        (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
        uint256 mask = 1 << bitPos;
        //xor 연산 > 다르면 1(유동성 존재) 같으면 0(유동성 없음) 반환 ::
        self[wordPos] ^= mask;
    }

    function nextInitializedTickWithinOneWord(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing,
        bool lte //for setting Direction
    ) internal view returns (int24 next, bool initialized) {
        int24 compressed = tick / tickSpacing;
         if (tick < 0 && tick % tickSpacing != 0) compressed--;

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self[wordPos] & mask;
            initialized = masked != 0;
            next = initialized
                ? (compressed - int24(uint24(bitPos - BitMath.mostSignificantBit(masked)))) * tickSpacing
                : (compressed - int24(uint24(bitPos))) * tickSpacing;
        } else {
            (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
            uint256 mask = ~((1 << bitPos) - 1);
            // and 연산 1&1 == 1 else 0
            uint256 masked = self[wordPos] & mask;
            initialized = masked != 0;
            // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick
            next = initialized
                ? (compressed + 1 + int24(uint24((BitMath.leastSignificantBit(masked) - bitPos)))) * tickSpacing
                : (compressed + 1 + int24(uint24((type(uint8).max - bitPos)))) * tickSpacing;
        }
    }
}
