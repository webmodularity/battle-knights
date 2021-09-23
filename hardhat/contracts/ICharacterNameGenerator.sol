//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

interface ICharacterNameGenerator {

    function getRandomName(string calldata gender) external view returns (string memory);

}