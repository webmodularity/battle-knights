//SPDX-License-Identifier: None
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IKnight.sol";
import "./IKnightGenerator.sol";
import "./IRandomDispatcher.sol";

contract Knight is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, Pausable, IKnight {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // Store Knight Metadata on chain
    mapping(uint256 => IKnight.SKnight) private knights;
    mapping(uint => uint8) private randomAttributeAttempts;
    IKnightGenerator private knightGeneratorContract;
    IRandomDispatcher private randomDispatcherContract;
    // Events
    event KnightMinted(uint indexed tokenId);

    constructor() ERC721("Battle Knights", "KNIGHT") {}

    function changeKnightGeneratorContract(address knightGeneratorContractAddress) external onlyOwner {
        knightGeneratorContract = IKnightGenerator(knightGeneratorContractAddress);
    }

    function changeRandomDispatcherContract(address randomDispatcherContractAddress) external onlyOwner {
        randomDispatcherContract = IRandomDispatcher(randomDispatcherContractAddress);
    }

    function updateTokenURI(uint tokenId,string calldata tokenUri) external override onlyOwner {
        _setTokenURI(tokenId, tokenUri);
    }

    function getPortraitCid(
        IKnight.Gender gender,
        IKnight.Race race,
        uint16 portraitId
    ) public view override returns (string memory) {
        return knightGeneratorContract.getPortraitCid(gender, race, portraitId);
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
        randomDispatcherContract.requestRandomNumber(IRandomDispatcher.Destination.Knight, tokenId);
    }

    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved");
        _burn(tokenId);
    }

    function getKnight(uint256 tokenId) public view returns (IKnight.SKnight memory) {
        require(_exists(tokenId));
        return knights[tokenId];
    }

    function useRandomNumber(uint tokenId, uint randomness) external override {
        require(msg.sender == address(randomDispatcherContract), "No access");
        if (tokenId > 0 && knights[tokenId].isMinting == true) {
            if (keccak256(abi.encodePacked(knights[tokenId].name)) == keccak256(abi.encodePacked(""))) {
                // Init Knight
                (knights[tokenId].name, knights[tokenId].gender, knights[tokenId].race, knights[tokenId].portraitId) =
                knightGeneratorContract.randomKnightInit(randomness);
                // Start another random request
                randomDispatcherContract.requestRandomNumber(IRandomDispatcher.Destination.Knight, tokenId);
            } else {
                // Roll Attributes
                knights[tokenId].attributes = knightGeneratorContract.randomKnightAttributes(
                    randomness,
                        knights[tokenId].race
                );
                randomAttributeAttempts[tokenId]++;
                if (knights[tokenId].attributes.strength != 0) {
                    knights[tokenId].isMinting = false;
                    emit KnightMinted(tokenId);
                    delete randomAttributeAttempts[tokenId];
                } else {
                    // Reroll attributes, sum did not equal 84
                    if (randomAttributeAttempts[tokenId] > 3) {
                        // Too many attempts , default to 12s
                        knights[tokenId].attributes = IKnight.Attributes(12, 12, 12, 12, 12, 12, 12);
                        knights[tokenId].isMinting = false;
                        emit KnightMinted(tokenId);
                        delete randomAttributeAttempts[tokenId];
                    } else {
                        // Start another random request
                        randomDispatcherContract.requestRandomNumber(IRandomDispatcher.Destination.Knight, tokenId);
                    }
                }
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
        require(!paused(), "Transfers paused");
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

}