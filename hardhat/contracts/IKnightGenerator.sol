//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "./IKnight.sol";

interface IKnightGenerator {

    function generateNewRandomKnight(uint seed) external returns (IKnight.SKnight memory);
    function addNameData(IKnight.Gender gender, IKnight.Race race, string[] calldata data) external;
    function addTitleData(IKnight.Race race, string[] calldata data) external;
    function getNamesCount(IKnight.Gender gender, IKnight.Race race) external view returns (uint);
    function getTitlesCount(IKnight.Race race) external view returns (uint);

}