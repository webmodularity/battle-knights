//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";
import "./IBattle.sol";
import "./ICharacterNameGenerator.sol";
import "./UniformRandomNumber.sol";

contract Knight is AccessControl, ERC721Enumerable, ERC721Pausable, IKnight {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _seasonIds;
    Counters.Counter private _battleIds;
    Counters.Counter private _fightIds;
    // Access Control
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SYNCER_ROLE = keccak256("SYNCER_ROLE");
    // Store current Battle Contract
    IBattle private battleContract;
    // Store current Character Name Generator Contract
    ICharacterNameGenerator private nameGeneratorContract;
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.KnightDetails) private knightDetails;
    // Store mapping of how many times names have been used
    mapping(bytes32 => uint8) private usedKnightNames;

    constructor() ERC721("Battle Knight Test", "KNGHT-TEST") {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function changeNameGeneratorContract(address nameGeneratorContractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        nameGeneratorContract = ICharacterNameGenerator(nameGeneratorContractAddress);
    }

    function changeBattleContract(address battleContractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        battleContract = IBattle(battleContractAddress);
    }

    function addMinterRole(address account_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account_);
    }

    function removeMinterRole(address account_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account_);
    }

    function getKnightName(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].name;
    }

    function getKnightGender(uint256 tokenId) external view returns (bytes1) {
        require(_exists(tokenId));
        return knightDetails[tokenId].gender;
    }

    function getKnightAttributes(uint256 tokenId) external view returns (IKnight.KnightAttributes memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].attributes;
    }

    function getKnightRecord(uint256 tokenId) external view returns (IKnight.KnightRecord memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].record;
    }

    function mintSpecial(
        address to,
        uint8[7] calldata attributes_,
        string memory knightName,
        bytes1 knightGender
    ) external onlyRole(MINTER_ROLE) {
        // Will start with tokenId 1
        _tokenIds.increment();
        uint knightId = _tokenIds.current();
        // Mint Knight
        _mint(to, knightId);
        // If no gender specified choose random
        if (knightGender != 0x4d && knightGender != 0x46) {
            knightGender = _getRandomKnightGender(uint(keccak256(abi.encodePacked(msg.sender))));
        }
        // If no name is specified choose random
        if (keccak256(abi.encodePacked(knightName)) == keccak256(abi.encodePacked(""))) {
            knightName = _getUniqueRandomKnightName(knightGender, uint(keccak256(abi.encodePacked(msg.sender))));
        }
        // Add Knight on chain
        knightDetails[knightId] = KnightDetails(
            knightName,
            knightGender,
            KnightAttributes(
                attributes_[0],
                attributes_[1],
                attributes_[2],
                attributes_[3],
                attributes_[4],
                attributes_[5],
                attributes_[6]
            ),
            KnightRecord(0,0,0,0)
        );
    }

    function _getUniqueRandomKnightName(bytes1 gender, uint seed) private returns (string memory) {
        uint8 attempts;
        uint8 nameIndex;
        string memory uniqueRandomName;
        while (attempts < 3) {
            attempts++;
            uniqueRandomName = nameGeneratorContract.getRandomName(gender, seed + attempts);
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
        return string(abi.encodePacked(uniqueRandomName, " ", _convertIntToRomanNumeral(++nameIndex)));
    }

    function _convertIntToRomanNumeral(uint8 number) private view returns (string memory) {
        string[10] memory c = ["",  "C",  "CC",  "CCC",  "CD", "D", "DC", "DCC", "DCCC", "CM"];
        string[10] memory x = ["",  "X",  "XX",  "XXX",  "XL", "L", "LX", "LXX", "LXXX", "XC"];
        string[10] memory i = ["",  "I",  "II",  "III",  "IV", "V", "VI", "VII", "VIII", "IX"];
        string memory cc = c[(number % 1000) / 100];
        string memory xx = x[(number % 100) / 10];
        string memory ii = i[number % 10];
        return string(abi.encodePacked(cc, xx, ii));
    }

    function _getRandomKnightGender(uint seed) private view returns (bytes1) {
        uint genderRandomInt = UniformRandomNumber.uniform(
            uint(keccak256(abi.encodePacked(seed, blockhash(block.number - 1), block.difficulty))),
            10
        );
        return genderRandomInt >= 8 ? bytes1(0x46) : bytes1(0x4d);
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
    override(AccessControl, IERC165, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}