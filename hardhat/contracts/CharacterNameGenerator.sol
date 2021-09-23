//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICharacterNameGenerator.sol";

contract CharacterNameGenerator is ICharacterNameGenerator {
    string[] internal namesMale;
    string[] internal namesFemale;

    function getRandomName(string calldata gender) external view override returns (string memory) {
        return keccak256(abi.encodePacked(gender)) == keccak256(abi.encodePacked("F")) ? "Female name" : "Male name";
    }
}