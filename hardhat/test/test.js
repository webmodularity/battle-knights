const { expect } = require("chai");
const { ethers } = require("hardhat");

const gameEnums = require("../scripts/gameEnums");

describe("Battle Knights", function () {
  let knightContract, knightGeneratorContract, battleContract;
  let signers = [];
  const testKnightAmount = 25;

  before(async () => {
    signers = await ethers.getSigners();
    // Deploy Knight contract
    const knightFactory = await ethers.getContractFactory("Knight");
    knightContract = await knightFactory.deploy();
    // Wait for contract to deploy
    await knightContract.deployed();
    // Deploy KnightGenerator contract
    const knightGeneratorFactory = await ethers.getContractFactory("KnightGenerator");
    knightGeneratorContract = await knightGeneratorFactory.deploy(knightContract.address);
    // Wait for contract to deploy
    await knightGeneratorContract.deployed();
    // Deploy Battle contract
    const battleFactory = await ethers.getContractFactory("Battle");
    battleContract = await battleFactory.deploy();
    // Wait for contract to deploy
    await knightGeneratorContract.deployed();
    // Set nameGenerator contract
    await knightContract.changeKnightGeneratorContract(knightGeneratorContract.address);
    // Set Battle contract
    await knightContract.changeBattleContract(battleContract.address);
    // Set SYNCER_ROLE for signers[1]
    await knightContract.addSyncerRole(signers[1].address);
  });

  describe("Knight Generator", function () {
    it("Should seed knightGenerator contract with test names and titles for each race", async function () {
      const testMaleNames = ["Rory", "Dan", "Cody", "Phil", "Alvaro"];
      const testFemaleNames = ["Colette", "Celeste", "Ellie", "Eva"];
      const testTitles = ["the Rogue", "the Patient", "the Viking", "the Crusher", "the Tainted", "the Crusader"];
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.addNameData(
            gameEnums.genders.findIndex("M"),
            i,
            testMaleNames
        );
        await knightGeneratorContract.addNameData(
            gameEnums.genders.findIndex("F"),
            i,
            testFemaleNames
        );
        await knightGeneratorContract.addTitleData(i, testTitles);
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(5);
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("F"),
            i
        )).to.equal(4);
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(6);
      }
    });

    it("Should remove the last title", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.removeTitleData(i, "the Crusader");
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(5);
      }
    });

    it("Revert any external calls to generateNewRandomKnight from outside Knight contract", async function () {
      await expect(knightGeneratorContract.connect(signers[2]).generateNewRandomKnight(100)).to.be.reverted;
    });

  });

  describe("Knight", function () {
    it(`Should mint ${testKnightAmount} randomly generated NFTs`, async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const mintTx = await knightContract.connect(signers[1]).mint();
        await mintTx.wait();
        expect(await knightContract.ownerOf(i)).to.equal(signers[1].address);
      }
    });

    it("Should store attributes on chain that are between 3-18 and sum to 84", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightAttributes = await knightContract.getAttributes(i);
        let knightAttributesSum = 0;
        for (let i = 0; i < 7; i++) {
          expect(knightAttributes[i]).to.be.within(3, 18);
          knightAttributesSum += knightAttributes[i];
        }
        expect(knightAttributesSum).to.equal(84);
      }
    });

    it("Should store name on chain", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightName = await knightContract.getName(i);
        expect(knightName).to.not.be.empty;
      }
    });

    it("Should store race on chain", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightRace = await knightContract.getRace(i);
        expect(knightRace).to.be.within(0, 7);
      }
    });

    it("Should store gender on chain", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightGender = await knightContract.getGender(i);
        expect(knightGender).to.be.within(0, 1);
      }
    });

    it("Should not be dead", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightIsDead = await knightContract.getIsDead(i);
        expect(knightIsDead).to.be.false;
      }
    });

    it("Contract should be pausable and revert all transfers while paused", async function () {
      const pauseTx = await knightContract.connect(signers[0]).togglePause();
      // Try mint
      await expect(knightContract.mint()).to.be.reverted;
      // Try transfer
      await expect(knightContract.connect(signers[1]).transferFrom(
          signers[1].address,
          signers[2].address,
          1
      )).to.be.reverted;
      // Try burn
      await expect(knightContract.connect(signers[1]).burn(1)).to.be.reverted;
      const unpauseTx = await knightContract.connect(signers[0]).togglePause();
      expect(await knightContract.totalSupply()).to.equal(testKnightAmount);
    });

    // it("Should log some knights to console", async function () {
    //   for (let i = 1;i <= testKnightAmount;i++) {
    //     const knightName = await knightContract.getName(i);
    //     const knightRace = gameEnums.races.enum[await knightContract.getRace(i)];
    //     const knightGender = gameEnums.genders.enum[await knightContract.getGender(i)];
    //     const knightAttributes = await knightContract.getAttributes(i);
    //     let knightAttributesSum = 0;
    //     for (let i = 0; i < 7; i++) {
    //       expect(knightAttributes[i]).to.be.within(3, 18);
    //       knightAttributesSum += knightAttributes[i];
    //     }
    //     console.log(`${knightName} ${knightGender} ${knightRace}`);
    //     console.log(`${knightAttributes[0]}, ${knightAttributes[1]}, ${knightAttributes[2]}, ${knightAttributes[3]}, ${knightAttributes[4]}, ${knightAttributes[5]}, ${knightAttributes[6]}`);
    //   }
    // });

  });

});