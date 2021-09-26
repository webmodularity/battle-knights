//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "./UniformRandomNumber.sol";

library Dice {
    enum DiceBiasDirections { Up, Down }

    function rollDiceSetBiased(
        uint8 resultSetSize,
        uint8 totalSetSize,
        uint upperLimit,
        uint seed,
        uint randomCounter,
        DiceBiasDirections biasDirection
    ) internal pure returns (uint) {
        require(totalSetSize > resultSetSize, "Not biased");
        uint[] memory allResults = new uint[](totalSetSize);
        uint[] memory resultMap;
        uint biasedSetSum;
        uint setCounter;
        for (uint i = 1;i <= totalSetSize;i++) {
            allResults[i - 1] = UniformRandomNumber.uniform(
                uint(keccak256(abi.encodePacked(seed, randomCounter + i))),
                    upperLimit
            ) + 1;
        }
        // Need to sort allResults
        if (biasDirection == DiceBiasDirections.Up) {
            for (uint c = allResults.length - 1;c > 0;c--) {
                biasedSetSum += allResults[c];
                setCounter++;
                if (setCounter == resultSetSize) {
                    return biasedSetSum;
                }
            }
        } else {
            for (uint c = 0;c <= allResults.length;c++) {
                biasedSetSum += allResults[c];
                setCounter++;
                if (setCounter == resultSetSize) {
                    return biasedSetSum;
                }
            }
        }
        // Fallback to returning current biasedSetSum, but should return above after walking up or down map
        return biasedSetSum;
    }

}