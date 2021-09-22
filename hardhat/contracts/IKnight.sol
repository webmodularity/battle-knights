//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IKnight is IERC721Enumerable {

    struct KnightAttributes {
        uint8 strength;
        uint8 vitality;
        uint8 size;
        uint8 stamina;
        uint8 dexterity;
        uint8 intelligence;
        uint8 luck;
    }

    struct KnightRecord {
        uint32 wins;
        uint32 losses;
        uint16 kills;
        uint16 tournamentVictories;
    }


    struct KnightDetails {
        string name;
        bytes1 gender;
        KnightAttributes attributes;
        KnightRecord record;
    }
}