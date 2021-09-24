//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

interface ICharacterNameGenerator {

    function getRandomName(bytes1 gender, uint seed) external view returns (string memory);

}