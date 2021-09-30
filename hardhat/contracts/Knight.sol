//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";
import "./IKnightGenerator.sol";
import "./IBattle.sol";

contract Knight is ERC721Enumerable, AccessControl, Pausable, IKnight {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.SKnight) private knights;
    //    Counters.Counter private _seasonIds;
    //    Counters.Counter private _battleIds;
    //    Counters.Counter private _fightIds;
    // Access Control
    bytes32 public constant SYNCER_ROLE = keccak256("SYNCER_ROLE");
    // Store current Battle Contract
    IBattle private battleContract;
    // Store current Character Name Generator Contract
    IKnightGenerator private knightGeneratorContract;


    constructor() ERC721("Battle Knight Test", "KNGHT-TEST") {
        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function changeKnightGeneratorContract(
        address knightGeneratorContractAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        knightGeneratorContract = IKnightGenerator(knightGeneratorContractAddress);
    }

    function changeBattleContract(address battleContractAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        battleContract = IBattle(battleContractAddress);
    }

    function addSyncerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(SYNCER_ROLE, account);
    }

    function removeSyncerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(SYNCER_ROLE, account);
    }

    function mintSpecial(
        address to,
        string memory name,
        IKnight.Race race,
        IKnight.Gender gender,
        uint8[7] calldata attributes
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenIds.increment();
        // Add Knight on chain
        knights[_tokenIds.current()] = SKnight(
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
        // Mint Knight
        _mint(to, _tokenIds.current());
    }

    function togglePause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function mint() public {
        _tokenIds.increment();
        // Generate new random knight and add on chain
        // Using pseudo-random for testing
        knights[_tokenIds.current()] = knightGeneratorContract.generateNewRandomKnight(
            uint(keccak256(abi.encode(_getPseudoRandom())))
        );
        // Mint Knight
        _mint(msg.sender, _tokenIds.current());
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved");
        _burn(tokenId);
    }

    function getName(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId));
        return knights[tokenId].name;
    }

    function getRace(uint256 tokenId) public view returns (IKnight.Race) {
        require(_exists(tokenId));
        return knights[tokenId].race;
    }

    function getGender(uint256 tokenId) public view returns (IKnight.Gender) {
        require(_exists(tokenId));
        return knights[tokenId].gender;
    }

    function getAttributes(uint256 tokenId) public view returns (IKnight.Attributes memory) {
        require(_exists(tokenId));
        return knights[tokenId].attributes;
    }

    function getRecord(uint256 tokenId) public view returns (IKnight.Record memory) {
        require(_exists(tokenId));
        return knights[tokenId].record;
    }

    function getIsDead(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId));
        return knights[tokenId].isDead;
    }

    function _getPseudoRandom() private view returns (uint) {
        return uint(keccak256(abi.encode(block.difficulty, block.timestamp, block.number)));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "Transfers paused");
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControl, IERC165, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}