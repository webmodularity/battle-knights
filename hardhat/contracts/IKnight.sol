//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IKnight is IERC721Enumerable {

    enum Gender {M, F}
    enum Race {Human, Dwarf, Orc, Ogre, Elf, Halfling, Undead, Gnome}

    struct Attributes {
        uint8 strength;
        uint8 vitality;
        uint8 size;
        uint8 stamina;
        uint8 dexterity;
        uint8 intelligence;
        uint8 luck;
    }

    struct Record {
        uint32 wins;
        uint32 losses;
        uint16 kills;
        uint16 tournamentWins;
    }

    struct SKnight {
        string name;
        Race race;
        Gender gender;
        Attributes attributes;
        Record record;
        bool isDead;
    }

}