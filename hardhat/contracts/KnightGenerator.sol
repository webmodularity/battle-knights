//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IKnightGenerator.sol";
import "./lib/UniformRandomNumber.sol";
import "./IKnight.sol";
import "./lib/Dice.sol";

contract KnightGenerator is Ownable, IKnightGenerator {
    address private knightContractAddress;
    string[] private maleNames;
    string[] private femaleNames;
    string[] private titles;
    // Store mapping of how many times names have been used
    mapping(bytes32 => uint8) private usedKnightNames;

    constructor(address _knightContractAddress) {
        knightContractAddress = _knightContractAddress;
    }

    function generateNewRandomKnight(uint seed) external override returns (IKnight.SKnight memory) {
        require(msg.sender == knightContractAddress, "Only calls from knightContract allowed!");
        IKnight.Gender gender = _getRandomKnightGender(uint(keccak256(abi.encode(seed, 1))));
        IKnight.Race race = _getRandomKnightRace(uint(keccak256(abi.encode(seed, 2))));
        string memory name = _getRandomKnightName(
            gender,
            race,
            uint(keccak256(abi.encode(seed, 3)))
        );
        IKnight.Attributes memory attributes = _getRandomKnightAttributes(uint(keccak256(abi.encode(seed, 4))), race);
        return IKnight.SKnight(name, race, gender, attributes, IKnight.Record(0,0,0,0), false);
    }

    function _getRandomKnightName(
        IKnight.Gender gender,
        IKnight.Race race,
        uint seed
    ) private returns (string memory) {
        uint8 attempts;
        uint8 nameIndex;
        string memory uniqueRandomName;
        while (attempts < 5) {
            attempts++;
            uniqueRandomName = _getRandomName(
                gender,
                race,
                uint(keccak256(abi.encode(seed, attempts)))
            );
            nameIndex = usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))];
            if (nameIndex == 0) {
                usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))]++;
                return uniqueRandomName;
            }
        }
        // Failed to find a unique name in 5 attempts - use this name + a roman numeral suffix
        if (nameIndex == 254) {
            // Reset back to 0
            delete usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))];
        } else {
            usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))]++;
        }
        return string(abi.encodePacked(
                uniqueRandomName,
                " ",
                _convertIntToRomanNumeral(++nameIndex)
            )
        );
    }

    function _getRandomName(
        IKnight.Gender gender,
        IKnight.Race race,
        uint seed
    ) private view returns (string memory) {
        // TODO Add Support for races
        // PURE?
        uint nameLength = gender == IKnight.Gender.F
        ? femaleNames.length
        : maleNames.length;
        uint selectedNameIndex = UniformRandomNumber.uniform(seed, nameLength);
        uint selectedTitleIndex = UniformRandomNumber.uniform(uint(keccak256(abi.encode(seed, 1))), titles.length);
        return gender == IKnight.Gender.F
        ? string(abi.encodePacked(femaleNames[selectedNameIndex], " ", titles[selectedTitleIndex]))
        : string(abi.encodePacked(maleNames[selectedNameIndex], " ", titles[selectedTitleIndex]));
    }

    function _convertIntToRomanNumeral(uint8 number) private pure returns (string memory) {
        string[10] memory c = ["",  "C",  "CC",  "CCC",  "CD", "D", "DC", "DCC", "DCCC", "CM"];
        string[10] memory x = ["",  "X",  "XX",  "XXX",  "XL", "L", "LX", "LXX", "LXXX", "XC"];
        string[10] memory i = ["",  "I",  "II",  "III",  "IV", "V", "VI", "VII", "VIII", "IX"];
        string memory cc = c[(number % 1000) / 100];
        string memory xx = x[(number % 100) / 10];
        string memory ii = i[number % 10];
        return string(abi.encodePacked(cc, xx, ii));
    }

    function addData(string calldata dataType, string[] calldata data) external override onlyOwner {
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

    function _getRandomKnightRace(uint seed) private pure returns (IKnight.Race) {
        uint raceRandomInt = UniformRandomNumber.uniform(seed, 100) + 1;
        if (raceRandomInt >= 80 && raceRandomInt <= 82) {
            return IKnight.Race.Dwarf;
        } else if (raceRandomInt >= 83 && raceRandomInt <= 85) {
            return IKnight.Race.Orc;
        } else if (raceRandomInt >= 86 && raceRandomInt <= 88) {
            return IKnight.Race.Ogre;
        } else if (raceRandomInt >= 89 && raceRandomInt <= 91) {
            return IKnight.Race.Elf;
        } else if (raceRandomInt >= 92 && raceRandomInt <= 94) {
            return IKnight.Race.Halfling;
        } else if (raceRandomInt >= 95 && raceRandomInt <= 97) {
            return IKnight.Race.Undead;
        } else if (raceRandomInt >= 98 && raceRandomInt <= 100) {
            return IKnight.Race.Gnome;
        }
        return IKnight.Race.Human;
    }

    function _getRandomKnightGender(uint seed) private pure returns (IKnight.Gender) {
        uint genderRandomInt = UniformRandomNumber.uniform(seed, 10);
        return genderRandomInt >= 8 ? IKnight.Gender.F : IKnight.Gender.M;
    }

    function _getRandomKnightAttributes(uint seed, IKnight.Race race) private pure returns (IKnight.Attributes memory) {
        uint attempts;
        while (attempts < 3) {
            uint8[7] memory attributes;
            attempts++;
            uint sum;
            for (uint i = 1;i <= 6;i++) {
                uint newSeed = uint(keccak256(abi.encode(seed, i + (attempts * 7))));
                if (i == 1 || ((sum / i > 10) && (sum / i < 13))) {
                    attributes[i - 1] = uint8(Dice.rollDiceSet(3, 6, newSeed));
                } else {
                    Dice.DiceBiasDirections diceBiasDirection = (sum / i < 10)
                    ? Dice.DiceBiasDirections.Up
                    : Dice.DiceBiasDirections.Down;
                    attributes[i - 1] = uint8(Dice.rollDiceSetBiased(3, 5, 6, newSeed, diceBiasDirection));
                }
                sum += attributes[i - 1];
            }
            if (sum >= 82 || sum <= 65) {
                // Not possible to hit 84, try again
                continue;
            }
            attributes[6] = uint8(84 - sum);
            _shuffleAttributes(attributes, uint(keccak256(abi.encode(seed, attributes[0], attributes[6]))));
            _sortAttributes(attributes, race);
            return IKnight.Attributes(
                attributes[0],
                attributes[1],
                attributes[2],
                attributes[3],
                attributes[4],
                attributes[5],
                attributes[6]
            );
        }
        // Fallback to 12s
        return IKnight.Attributes(12, 12, 12, 12, 12, 12, 12);
    }

    function _shuffleAttributes(uint8[7] memory attributes, uint seed) private pure {
        for (uint i = 0; i < 7; i++) {
            uint n = UniformRandomNumber.uniform(
                uint(keccak256(abi.encode(seed, i))),
                7
            );
            uint8 temp = attributes[n];
            attributes[n] = attributes[i];
            attributes[i] = temp;
        }
    }

    function _sortAttributes(uint8[7] memory attributes, IKnight.Race race) private pure {
        if (race != IKnight.Race.Human) {
            uint8 maxAttributeVal;
            uint maxAttributeIndex;
            uint bonusAttributeIndex;
            // Find max attribute index + value
            for (uint i = 0;i < 7;i++) {
                if (attributes[i] >= maxAttributeVal) {
                    maxAttributeVal = attributes[i];
                    maxAttributeIndex = i;
                }
            }
            // Define bonusAttributeIndex based on race
            if (race == IKnight.Race.Orc) {
                // Strength
                bonusAttributeIndex = 0;
            } else if (race == IKnight.Race.Dwarf) {
                // Vitality
                bonusAttributeIndex = 1;
            } else if (race == IKnight.Race.Ogre) {
                // Size
                bonusAttributeIndex = 2;
            } else if (race == IKnight.Race.Undead) {
                // Stamina
                bonusAttributeIndex = 3;
            } else if (race == IKnight.Race.Elf) {
                // Dexterity
                bonusAttributeIndex = 4;
            } else if (race == IKnight.Race.Gnome) {
                // Intelligence
                bonusAttributeIndex = 5;
            } else if (race == IKnight.Race.Halfling) {
                // Luck
                bonusAttributeIndex = 6;
            }
            // Switch maxAttributeIndex and bonusAttributeIndex values if bonusAttribute value is already max
            if (bonusAttributeIndex != maxAttributeIndex) {
                attributes[maxAttributeIndex] = attributes[bonusAttributeIndex];
                attributes[bonusAttributeIndex] = maxAttributeVal;
            }
        }
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

}