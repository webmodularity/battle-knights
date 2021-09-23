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

contract Knight is AccessControl, ERC721Enumerable, ERC721Pausable, IKnight {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _seasonIds;
    Counters.Counter private _battleIds;
    Counters.Counter private _fightIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SYNCER_ROLE = keccak256("SYNCER_ROLE");
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.KnightDetails) private knightDetails;
    // Store current Battle Contract
    IBattle private battleContract;
    // Store current Character Name Generator Contract
    ICharacterNameGenerator private nameGeneratorContract;

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

    function getKnightName(uint256 tokenId) external view returns(string memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].name;
    }

    function getKnightGender(uint256 tokenId) external view returns(bytes1) {
        require(_exists(tokenId));
        return knightDetails[tokenId].gender;
    }

    function getKnightAttributes(uint256 tokenId) external view returns(IKnight.KnightAttributes memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].attributes;
    }

    function getKnightRecord(uint256 tokenId) external view returns(IKnight.KnightRecord memory) {
        require(_exists(tokenId));
        return knightDetails[tokenId].record;
    }

    function mintSpecial(
        address to,
        uint8[7] calldata attributes,
        string calldata knightName,
        bytes1 knightGender,
        string calldata tokenUri
    ) external onlyRole(MINTER_ROLE) {
        // Will start with tokenId 1
        _tokenIds.increment();
        uint knightId = _tokenIds.current();
        // Mint Knight
        _mint(to, knightId);
        // Add Knight on chain
        knightDetails[knightId] = KnightDetails(
            knightName,
            knightGender,
            KnightAttributes(
                attributes[0],
                attributes[1],
                attributes[2],
                attributes[3],
                attributes[4],
                attributes[5],
                attributes[6]
            ),
            KnightRecord(0,0,0,0)
        );
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