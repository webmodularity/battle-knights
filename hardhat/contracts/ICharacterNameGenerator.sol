//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "./IKnight.sol";

interface ICharacterNameGenerator {

    function getRandomName(IKnight.Gender gender,IKnight.Race race, uint seed) external view returns (string memory);
    function convertIntToRomanNumeral(uint8 number) external pure returns (string memory);

}