//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";

contract Knight is AccessControl, ERC721Enumerable, ERC721Pausable, IKnight {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => IKnight.KnightDetails) internal knightDetails;

    constructor() ERC721("Battle Knight Test", "BNITE-TEST") {
        // Grant the contract deployer the default admin role: it will be able
        // to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mintSpecial(
        address _to,
        uint8[7] memory _attributes,
        string memory _knightName,
        string memory _tokenUri
    ) external onlyRole(MINTER_ROLE) {
        // Will start with tokenId 1 rather than 0
        _tokenIds.increment();
        uint knightId = _tokenIds.current();
        // Mint Knight
        _mint(_to, knightId);
        // Add Knight on chain
        knightDetails[knightId] = KnightDetails(
            _knightName,
            KnightAttributes(
                _attributes[0],
                _attributes[1],
                _attributes[2],
                _attributes[3],
                _attributes[4],
                _attributes[5],
                _attributes[6]
            ),
            KnightStats(0,0,0,0)
        );
    }

    function getKnightName(uint256 _tokenId) external view returns(string memory) {
        require(_exists(_tokenId));
        return knightDetails[_tokenId].name;
    }

    function getKnightAttributes(uint256 _tokenId) external view returns(IKnight.KnightAttributes memory) {
        require(_exists(_tokenId));
        return knightDetails[_tokenId].attributes;
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

    function addMinterRole(address _account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, _account);
    }

    function removeMinterRole(address _account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, _account);
    }
}