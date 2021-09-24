const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Battle Knights", function () {
  let knightContract, nameGeneratorContract, battleContract;
  let signers = [];

  before(async () => {
    signers = await ethers.getSigners();
    // Deploy CharacterNameGenerator contract
    const nameGeneratorFactory = await ethers.getContractFactory("CharacterNameGenerator");
    nameGeneratorContract = await nameGeneratorFactory.deploy();
    // Wait for contract to deploy
    await nameGeneratorContract.deployed();
    // Set some test names and titles
    const maleNamesTx = await nameGeneratorContract.addData('maleNames', ["Rory", "Dan", "Cody", "Phil", "Alvaro"]);
    await maleNamesTx.wait();
    const femaleNamesTx = await nameGeneratorContract.addData('femaleNames', ["Colette", "Celeste", "Ellie", "Eva"]);
    await femaleNamesTx.wait();
    const titlesTx = await nameGeneratorContract.addData('titles', ["the Rogue", "the Patient", "the Viking", "the Crusher"]);
    await titlesTx.wait();
    // Deploy Battle contract
    const battleFactory = await ethers.getContractFactory("Battle");
    battleContract = await battleFactory.deploy();
    // Wait for contract to deploy
    await nameGeneratorContract.deployed();
    // Deploy Knight contract
    const knightFactory = await ethers.getContractFactory("Knight");
    knightContract = await knightFactory.deploy();
    // Wait for contract to deploy
    await knightContract.deployed();
    // Set nameGenerator contract
    await knightContract.changeNameGeneratorContract(nameGeneratorContract.address);
    // Set Battle contract
    await knightContract.changeBattleContract(battleContract.address);
    // Set MINTER_ROLE for signers[1]
    await knightContract.addMinterRole(signers[1].address);
  });

  describe("Character Name Generator", function () {
    it("Should generate random name", async function () {
      const randomName = await nameGeneratorContract.getRandomName(
          "0x" + "M".charCodeAt(0).toString(16),
          Math.floor(Math.random() * 1000)
      );
      expect(randomName).to.not.be.empty;
    });
  });

  describe("Knight", function () {
    it("Should mint 50 randomly generated NFTs via mintSpecial method", async function () {
      for (let i = 1;i <= 50;i++) {
        const mintTx = await knightContract.connect(signers[1]).mintSpecial(
            signers[2].address,
            [18, 18, 18, 18, 18, 18, 18],
            "",
            "0x00"//"0x" + "F".charCodeAt(0).toString(16)
        );
        await mintTx.wait();
        expect(await knightContract.ownerOf(i)).to.equal(signers[2].address);
      }
    });

    it("Should store attributes on chain for new Knight NFT", async function () {
      const firstKnightAttributes = await knightContract.getKnightAttributes(1);
      for (let i = 0;i < 6;i++) {
        expect(firstKnightAttributes[i]).to.equal(18);
      }
    });

    it("Should store name on chain for new Knight NFT", async function () {
      for (let i = 1;i <= 50;i++) {
        const knightName = await knightContract.getKnightName(i);
        expect(knightName).to.not.be.empty;
      }
    });

    it("Should store gender on chain for new Knight NFT", async function () {
      const firstKnightGender = await knightContract.getKnightGender(1);
      expect(firstKnightGender).to.be.oneOf(
          ["0x" + "F".charCodeAt(0).toString(16), "0x" + "M".charCodeAt(0).toString(16)]
      );
    });
  });
});