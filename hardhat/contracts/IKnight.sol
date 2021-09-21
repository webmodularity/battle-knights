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

    struct KnightStats {
        uint32 wins;
        uint32 losses;
        uint32 kills;
        uint32 tournamentVictories;
    }

    struct KnightDetails {
        string name;
        KnightAttributes attributes;
        KnightStats stats;
    }
}