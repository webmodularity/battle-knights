//SPDX-License-Identifier: None
pragma solidity ^0.8.5;

import "./IKnight.sol";

interface IKnightGenerator {

    function randomKnightInit(uint seed) external returns (
        string memory,
        IKnight.Gender,
        IKnight.Race,
        uint16
    );
    function randomKnightAttributes(
        uint seed,
        IKnight.Race race
    ) external returns (IKnight.Attributes memory);
    function addNameData(IKnight.Gender gender, IKnight.Race race, string[] calldata data) external;
    function removeNameData(IKnight.Gender gender, IKnight.Race race, string calldata data) external;
    function addTitleData(IKnight.Race race, string[] calldata data) external;
    function removeTitleData(IKnight.Race race, string calldata data) external;
    function addActivePortraitIndex(IKnight.Gender gender, IKnight.Race race, uint16[] memory data) external;
    function removeActivePortraitIndex(IKnight.Gender gender, IKnight.Race race, uint16 data) external;
    function getNamesCount(IKnight.Gender gender, IKnight.Race race) external view returns (uint);
    function getTitlesCount(IKnight.Race race) external view returns (uint);
    function getActivePortraitsCount(IKnight.Gender gender, IKnight.Race race) external view returns (uint);
    function addPortraitData(IKnight.Gender gender, IKnight.Race race, string[] calldata data) external;
    function getPortraitCid(IKnight.Gender gender, IKnight.Race race, uint16 portraitId) external view returns (string memory);

}