//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
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
    // VRF Request mapping to tokenId
    mapping(bytes32 => uint) private randomRequestToTokenId;
    //mapping(uint => uint) private tokenIdToSeed;
    uint vrfFee;
    bytes32 vrfKeyHash;
    // Store Portrait IPFS CIDs
    mapping(IKnight.Race => string[]) private malePortraitMap;
    mapping(IKnight.Race => string[]) private femalePortraitMap;
    // Store current Battle Contract
//    IBattle private battleContract;
    // Store current Character Name Generator Contract
    IKnightGenerator private knightGeneratorContract;

    event RequestedRandomness(bytes32 requestId);
    event KnightMinted(uint indexed tokenId);


    constructor(address _vrfCoordinator, address _link, bytes32 _keyHash, uint _fee)
        ERC721("Battle Knights Test", "KNGHT-TEST")
        VRFConsumerBase(_vrfCoordinator, _link)
    {
        vrfKeyHash = _keyHash;
        vrfFee = _fee;
    }

    function changeKnightGeneratorContract(address knightGeneratorContractAddress) external onlyOwner {
        knightGeneratorContract = IKnightGenerator(knightGeneratorContractAddress);
    }

//    function changeBattleContract(address battleContractAddress) external onlyOwner {
//        battleContract = IBattle(battleContractAddress);
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
        require(LINK.balanceOf(address(this)) >= vrfFee, "Not enough LINK");
        _tokenIds.increment();
        uint tokenId = _tokenIds.current();
        // Mint Knight
        _mint(msg.sender, tokenId);
        // Init empty SKnight for this tokenId
        knights[tokenId] = SKnight(
            "",
            IKnight.Gender.M,
            IKnight.Race.Human,
            IKnight.Attributes(0, 0, 0, 0, 0, 0, 0),
            0,
            IKnight.Record(0, 0, 0, 0),
            false,
            true
        );
        bytes32 randomRequestId = requestRandomness(vrfKeyHash, vrfFee);
        emit RequestedRandomness(randomRequestId);
        randomRequestToTokenId[randomRequestId] = tokenId;
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

    function getIsMinting(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId));
        return knights[tokenId].isMinting;
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint tokenId = randomRequestToTokenId[requestId];
        if (tokenId > 0 && knights[tokenId].isMinting == true) {
            if (keccak256(abi.encodePacked(knights[tokenId].name)) == keccak256(abi.encodePacked(""))) {
                // Init Knight
                (knights[tokenId].name, knights[tokenId].gender, knights[tokenId].race, knights[tokenId].portraitId) =
                knightGeneratorContract.randomKnightInit(randomness);
                bytes32 randomRequestId = requestRandomness(vrfKeyHash, vrfFee);
                randomRequestToTokenId[randomRequestId] = tokenId;
                emit RequestedRandomness(randomRequestId);
            } else {
                // Roll Attributes
                knights[tokenId].attributes = knightGeneratorContract.randomKnightAttributes(
                    randomness,
                    knights[tokenId].race
                );
                if (knights[tokenId].attributes.strength != 0) {
                    knights[tokenId].isMinting = false;
                    emit KnightMinted(tokenId);
                } else {
                    // Reroll attributes, sum did not equal 84
                    // TODO: limit attempts here
                    bytes32 randomRequestId = requestRandomness(vrfKeyHash, vrfFee);
                    randomRequestToTokenId[randomRequestId] = tokenId;
                    emit RequestedRandomness(randomRequestId);
                }
            }
            // GC old request
            delete randomRequestToTokenId[requestId];
        }
    }

    function toByte(uint8 _uint8) public pure returns (bytes1) {
        if(_uint8 < 10) {
            return bytes1(_uint8 + 48);
        } else {
            return bytes1(_uint8 + 87);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "Transfers paused");
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

}