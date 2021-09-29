//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "./IKnight.sol";

interface IKnightGenerator {

    function generateNewRandomKnight(uint seed) external returns (IKnight.SKnight memory);
    function addData(string calldata dataType, string[] calldata data) external;

}