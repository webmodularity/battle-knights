//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
//import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";
import "./IBattle.sol";
import "./ICharacterNameGenerator.sol";
import "./lib/Dice.sol";

contract Knight is ERC721Enumerable, ERC721Pausable, IKnight {
    using Counters for Counters.Counter;
    // Counters
    Counters.Counter private _tokenIds;
    Counters.Counter private _seasonIds;
    Counters.Counter private _battleIds;
    Counters.Counter private _fightIds;
    // Access Control
    //bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    //bytes32 public constant SYNCER_ROLE = keccak256("SYNCER_ROLE");
    // Store current Battle Contract
    IBattle private battleContract;
    // Store current Character Name Generator Contract
    ICharacterNameGenerator private nameGeneratorContract;
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.SKnight) private knights;
    // Store mapping of how many times names have been used
    mapping(bytes32 => uint8) private usedKnightNames;

    constructor() ERC721("Battle Knight Test", "KNGHT-TEST") {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        //_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function changeNameGeneratorContract(address nameGeneratorContractAddress) external {
        nameGeneratorContract = ICharacterNameGenerator(nameGeneratorContractAddress);
    }

    function changeBattleContract(address battleContractAddress) external {
        battleContract = IBattle(battleContractAddress);
    }
//
//    function addMinterRole(address account_) external onlyRole(DEFAULT_ADMIN_ROLE) {
//        grantRole(MINTER_ROLE, account_);
//    }
//
//    function removeMinterRole(address account_) external onlyRole(DEFAULT_ADMIN_ROLE) {
//        revokeRole(MINTER_ROLE, account_);
//    }

    function getName(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return knights[tokenId].name;
    }

    function getRace(uint256 tokenId) external view returns (IKnight.Race) {
        require(_exists(tokenId));
        return knights[tokenId].race;
    }

    function getGender(uint256 tokenId) external view returns (IKnight.Gender) {
        require(_exists(tokenId));
        return knights[tokenId].gender;
    }

    function getAttributes(uint256 tokenId) external view returns (IKnight.Attributes memory) {
        require(_exists(tokenId));
        return knights[tokenId].attributes;
    }

    function getRecord(uint256 tokenId) external view returns (IKnight.Record memory) {
        require(_exists(tokenId));
        return knights[tokenId].record;
    }

    function getIsDead(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId));
        return knights[tokenId].isDead;
    }

    function mint() external {
        _tokenIds.increment();
        uint knightId = _tokenIds.current();
        // Mint Knight
        _mint(msg.sender, knightId);
        // Randomize Knight - Using pseudoRandom for testing
        IKnight.Gender gender = _getRandomKnightGender(uint(keccak256(abi.encode(_getPseudoRandom(), 1))));
        IKnight.Race race = _getRandomKnightRace(uint(keccak256(abi.encode(_getPseudoRandom(), 2))));
        string memory name = _getUniqueRandomKnightName(
            gender,
            race,
            uint(keccak256(abi.encode(_getPseudoRandom(), 3)))
        );
        IKnight.Attributes memory attributes = _getRandomKnightAttributes(uint(keccak256(abi.encode(name))), race);
        // Add Knight on chain
        knights[knightId] = SKnight(name, race, gender, attributes, IKnight.Record(0,0,0,0), false);
    }

    function mintSpecial(
        address to,
        string memory name,
        IKnight.Race race,
        IKnight.Gender gender,
        uint8[7] calldata attributes
    ) external {
        _tokenIds.increment();
        uint knightId = _tokenIds.current();
        // Mint Knight
        _mint(to, knightId);
        // Add Knight on chain
        knights[knightId] = SKnight(
            name,
            race,
            gender,
            IKnight.Attributes(
                attributes[0],
                attributes[1],
                attributes[2],
                attributes[3],
                attributes[4],
                attributes[5],
                attributes[6]
            ),
            IKnight.Record(0,0,0,0),
            false
        );
    }

    function _getUniqueRandomKnightName(
        IKnight.Gender gender,
        IKnight.Race race,
        uint seed
    ) private returns (string memory) {
        uint8 attempts;
        uint8 nameIndex;
        string memory uniqueRandomName;
        while (attempts < 3) {
            attempts++;
            uniqueRandomName = nameGeneratorContract.getRandomName(
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
        // Failed to find a unique name in 3 attempts - use this name + a roman numeral suffix
        if (nameIndex == 254) {
            // Reset back to 0
            delete usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))];
        } else {
            usedKnightNames[keccak256(abi.encodePacked(uniqueRandomName))]++;
        }
        return string(abi.encodePacked(
                uniqueRandomName,
                " ",
                nameGeneratorContract.convertIntToRomanNumeral(++nameIndex)
            )
        );
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

    function _getRandomKnightAttributes(uint seed, IKnight.Race race) private returns (IKnight.Attributes memory) {
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

    function _getPseudoRandom() private view returns (uint) {
        return uint(keccak256(abi.encode(block.difficulty, block.timestamp, block.number)));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(IERC165, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}