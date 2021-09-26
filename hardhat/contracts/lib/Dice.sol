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
    ) internal returns (uint) {
        require(totalSetSize > resultSetSize, "Not biased");
        uint[] memory allResults = new uint[](totalSetSize);
        uint biasedSetSum;
        uint setCounter;
        for (uint i = 1;i <= totalSetSize;i++) {
            allResults[i - 1] = UniformRandomNumber.uniform(
                uint(keccak256(abi.encodePacked(seed, randomCounter + i))),
                    upperLimit
            ) + 1;
        }
        // Sort allResults
        sortArray(allResults);
        if (biasDirection == DiceBiasDirections.Up) {
            for (uint c = allResults.length - 1;c >= 0;c--) {
                biasedSetSum += allResults[c];
                setCounter++;
                if (setCounter == resultSetSize) {
                    break;
                }
            }
        } else {
            for (uint c = 0;c <= allResults.length;c++) {
                biasedSetSum += allResults[c];
                setCounter++;
                if (setCounter == resultSetSize) {
                    break;
                }
            }
        }
        return biasedSetSum;
    }

    function sortArray(uint[] memory arr) internal pure {
        uint l = arr.length;
        for(uint i = 0; i < l; i++) {
            for(uint j = i+1; j < l ;j++) {
                if(arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

}