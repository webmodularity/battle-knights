//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

interface IKnight {

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
        Gender gender;
        Race race;
        Attributes attributes;
        uint16 portraitId;
        Record record;
        bool isDead;
        bool isMinting;
    }

    function addPortraitData(IKnight.Gender gender, IKnight.Race race, string[] calldata data) external;
    function getPortraitCid(IKnight.Gender gender, IKnight.Race race, uint16 portraitId) external view returns (string memory);

}