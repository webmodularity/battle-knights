//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICharacterNameGenerator.sol";
import "./lib/UniformRandomNumber.sol";
import "./IKnight.sol";

contract CharacterNameGenerator is ICharacterNameGenerator, Ownable {
    string[] internal maleNames;
    string[] internal femaleNames;
    string[] internal titles;

    function getRandomName(
        IKnight.Gender gender,
        IKnight.Race race,
        uint seed
    ) external view override returns (string memory) {
        // TODO Add Support for races
        uint nameLength = gender == IKnight.Gender.F
            ? femaleNames.length
            : maleNames.length;
        uint selectedNameIndex = UniformRandomNumber.uniform(seed, nameLength);
        uint selectedTitleIndex = UniformRandomNumber.uniform(uint(keccak256(abi.encode(seed, 1))), titles.length);
        return gender == IKnight.Gender.F
            ? string(abi.encodePacked(femaleNames[selectedNameIndex], " ", titles[selectedTitleIndex]))
            : string(abi.encodePacked(maleNames[selectedNameIndex], " ", titles[selectedTitleIndex]));
    }

    function convertIntToRomanNumeral(uint8 number) external pure override returns (string memory) {
        string[10] memory c = ["",  "C",  "CC",  "CCC",  "CD", "D", "DC", "DCC", "DCCC", "CM"];
        string[10] memory x = ["",  "X",  "XX",  "XXX",  "XL", "L", "LX", "LXX", "LXXX", "XC"];
        string[10] memory i = ["",  "I",  "II",  "III",  "IV", "V", "VI", "VII", "VIII", "IX"];
        string memory cc = c[(number % 1000) / 100];
        string memory xx = x[(number % 100) / 10];
        string memory ii = i[number % 10];
        return string(abi.encodePacked(cc, xx, ii));
    }

    function addData(string calldata dataType, string[] calldata data) external onlyOwner {
        // TODO Add Support for races
        if (keccak256(abi.encodePacked(dataType)) == keccak256(abi.encodePacked("maleNames"))) {
            for (uint i = 0;i < data.length;i++) {
                maleNames.push(data[i]);
            }
        } else if (keccak256(abi.encodePacked(dataType)) == keccak256(abi.encodePacked("femaleNames"))) {
            for (uint i = 0;i < data.length;i++) {
                femaleNames.push(data[i]);
            }
        } else if (keccak256(abi.encodePacked(dataType)) == keccak256(abi.encodePacked("titles"))) {
            for (uint i = 0;i < data.length;i++) {
                titles.push(data[i]);
            }
        }
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

}