//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICharacterNameGenerator.sol";
import "./UniformRandomNumber.sol";

contract CharacterNameGenerator is ICharacterNameGenerator, Ownable {
    string[] internal maleNames;
    string[] internal femaleNames;
    string[] internal titles;

    function getRandomName(bytes1 gender, uint seed) external view override returns (string memory) {
        uint nameLength = gender == 0x46
            ? femaleNames.length
            : maleNames.length;
        uint selectedNameIndex = UniformRandomNumber.uniform(
            uint(keccak256(abi.encodePacked(seed, blockhash(block.number - 1), block.difficulty))),
            nameLength
        );
        uint selectedTitleIndex = UniformRandomNumber.uniform(
            uint(keccak256(abi.encodePacked(seed + 1, blockhash(block.number - 1), block.difficulty, block.coinbase))),
            titles.length
        );
        return gender == 0x46
            ? string(abi.encodePacked(femaleNames[selectedNameIndex], " ", titles[selectedTitleIndex]))
            : string(abi.encodePacked(maleNames[selectedNameIndex], " ", titles[selectedTitleIndex]));
    }

    function addData(string calldata dataType, string[] calldata data) external onlyOwner {
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