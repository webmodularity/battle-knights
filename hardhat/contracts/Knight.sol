//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";
import "./IKnightGenerator.sol";
import "./IBattle.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Knight is ERC721Enumerable, Ownable, Pausable, IKnight, VRFConsumerBase {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.SKnight) private knights;
    // Minting
    uint[] mintingKnightIds;
    mapping(uint256 => IKnight.KnightMinting) private knightsMinting;
    // Store Portrait IPFS CIDs
    mapping(IKnight.Race => string[]) private malePortraitMap;
    mapping(IKnight.Race => string[]) private femalePortraitMap;
    //    Counters.Counter private _seasonIds;
    //    Counters.Counter private _battleIds;
    //    Counters.Counter private _fightIds;
    // Access Control
//    bytes32 public constant SYNCER_ROLE = keccak256("SYNCER_ROLE");
    // Store current Battle Contract
    IBattle private battleContract;
    // Store current Character Name Generator Contract
    IKnightGenerator private knightGeneratorContract;


    constructor()
        ERC721("Battle Knight Test", "KNGHT-TEST")
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        )
    {
//        // Grant the contract deployer the default admin role: it will be able to grant and revoke any roles
//        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function changeKnightGeneratorContract(address knightGeneratorContractAddress) external onlyOwner {
        knightGeneratorContract = IKnightGenerator(knightGeneratorContractAddress);
    }

    function changeBattleContract(address battleContractAddress) external onlyOwner {
        battleContract = IBattle(battleContractAddress);
    }

//    function addSyncerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
//        grantRole(SYNCER_ROLE, account);
//    }
//
//    function removeSyncerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
//        revokeRole(SYNCER_ROLE, account);
//    }

    function addPortraitData(
        IKnight.Gender gender,
        IKnight.Race race,
        string[] calldata data
    ) external override onlyOwner {
        uint16[] memory newPortraitIds = new uint16[](data.length);
        if (gender == IKnight.Gender.F) {
            for (uint i = 0;i < data.length;i++) {
                femalePortraitMap[race].push(data[i]);
                newPortraitIds[i] = uint16(femalePortraitMap[race].length - 1);
            }

        } else {
            for (uint i = 0;i < data.length;i++) {
                malePortraitMap[race].push(data[i]);
                newPortraitIds[i] = uint16(malePortraitMap[race].length - 1);
            }
        }
        // Add these new CIDs to Active Portrait list of KnightGenerator
        knightGeneratorContract.addActivePortraitIndex(gender, race, newPortraitIds);
    }

    function getPortraitCid(
        IKnight.Gender gender,
        IKnight.Race race,
        uint16 portraitId
    ) public view override returns (string memory) {
        if (gender == IKnight.Gender.F) {
            return femalePortraitMap[race][portraitId];
        } else {
            return malePortraitMap[race][portraitId];
        }
    }

    function togglePause() external onlyOwner {
        if (!paused()) {
            _pause();
        } else {
            _unpause();
        }
    }

    function mint() public {
        _tokenIds.increment();
        mintingKnightIds.push(_tokenIds.current());
        // Mint Knight
        _mint(msg.sender, _tokenIds.current());
        //        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        bytes32 keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        uint256 fee = 0.1 * 10 ** 18;
        //bytes32 randomRequestId = requestRandomness(keyHash, fee);
    }

    function generateKnightInit(uint tokenId) external {
        (
        string memory name,
        IKnight.Gender gender,
        IKnight.Race race,
        uint16 portraitId
        ) = knightGeneratorContract.randomKnightInit(_getPseudoRandom());
        knightsMinting[_tokenIds.current()] = KnightMinting(name, gender, race, portraitId, IKnight.Attributes(0, 0, 0, 0, 0, 0, 0));
    }

    function generateKnightAttributes(uint tokenId) external {
        knightsMinting[_tokenIds.current()].attributes = knightGeneratorContract.randomKnightAttributes(
            _getPseudoRandom(),
            knightsMinting[tokenId].race
        );
    }

    function commitNewKnight(uint tokenId) external {
        knights[tokenId] = IKnight.SKnight(
            knightsMinting[tokenId].name,
            knightsMinting[tokenId].gender,
            knightsMinting[tokenId].race,
            knightsMinting[tokenId].attributes,
            knightsMinting[tokenId].portraitId,
            IKnight.Record(0, 0, 0, 0),
            false
        );
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

//    function getRecord(uint256 tokenId) public view returns (IKnight.Record memory) {
//        require(_exists(tokenId));
//        return knights[tokenId].record;
//    }

    function getIsDead(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId));
        return knights[tokenId].isDead;
    }

    function _getPseudoRandom() private view returns (uint) {
        return uint(keccak256(abi.encode(block.difficulty, block.timestamp, block.number)));
    }

    /**
 * Requests randomness
 */
    function getRandomNumber() public returns (bytes32 requestId) {
//        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        bytes32 keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        uint256 fee = 0.1 * 10 ** 18;
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        // Generate new random knight and add on chain
        // Using pseudo-random for testing
        //knights[_tokenIds.current()] = knightGeneratorContract.generateNewRandomKnight(
        //    uint(keccak256(abi.encode(_getPseudoRandom())))
        //);
        //        (IKnight.Gender gender, IKnight.Race race, uint16 portraitId) = knightGeneratorContract.initRandomKnight(
        //            _tokenIds.current(),
        //            _getPseudoRandom()
        //        );
        //        knightsMinting[_tokenIds.current()] = KnightMinting("", gender, race, portraitId);
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
    override(IERC165, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}