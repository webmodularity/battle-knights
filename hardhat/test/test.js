const { expect } = require("chai");
const { ethers } = require("hardhat");

const gameEnums = require("../scripts/gameEnums");

let knightContract, knightGeneratorContract, battleContract, linkToken, vrfCoordinatorMock;
let signers = [];
const testKnightAmount = 25;
// Test data
const testMaleNames = ["Rory", "Dan", "Cody", "Phil", "Alvaro"];
const testFemaleNames = ["Colette", "Celeste", "Ellie", "Eva"];
const testTitles = ["the Rogue", "the Patient", "the Viking", "the Crusher", "the Tainted", "the Crusader"];
const testMalePortraits = ["maKJHSYYSUYJSS", "maIUYUYUYUY", "maGHUDFGHSVBWY", "maHGTXBWSKJDG", "maHDFTSDFSHSC"];
const testFemalePortraits = ["feKJHSYYSUYJSS", "feIUYUYUYUY", "feGHUDFGHSVBWY", "feHGTXBWSKJDG", "feHDFTSDFSHSC"];

describe("Battle Knights", function () {
  before(async () => {
    await deployments.fixture(['mocks', 'knight']);
    signers = await ethers.getSigners();

    const LinkToken = await deployments.get('LinkToken');
    linkToken = await ethers.getContractAt('LinkToken', LinkToken.address);
    const Knight = await deployments.get('Knight');
    knightContract = await ethers.getContractAt('Knight', Knight.address);
    const KnightGenerator = await deployments.get('KnightGenerator');
    knightGeneratorContract = await ethers.getContractAt('KnightGenerator', KnightGenerator.address);
    const VRFCoordinatorMock = await deployments.get('VRFCoordinatorMock');
    vrfCoordinatorMock = await ethers.getContractAt('VRFCoordinatorMock', VRFCoordinatorMock.address);
  });

  describe("Knight Generator", function () {
    it("Should seed knightGenerator contract with test names, titles, and portraits for each race", async function () {
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
        await knightContract.addPortraitData(
            gameEnums.genders.findIndex("M"),
            i,
            testMalePortraits
        );
        await knightContract.addPortraitData(
            gameEnums.genders.findIndex("F"),
            i,
            testFemalePortraits
        );
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(5);
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("F"),
            i
        )).to.equal(4);
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(6);
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(5);
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("F"),
            i
        )).to.equal(5);
      }
    });

    it("Should remove a random NAME from each race/gender", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.removeNameData(
            gameEnums.genders.findIndex("F"),
            i,
            testFemaleNames[Math.floor(Math.random() * testFemaleNames.length)]
        );
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("F"),
            i
        )).to.equal(testFemaleNames.length - 1);
        await knightGeneratorContract.removeNameData(
            gameEnums.genders.findIndex("M"),
            i,
            testMaleNames[Math.floor(Math.random() * testMaleNames.length)]);
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(testMaleNames.length - 1);
      }
    });

    it("Should remove a random TITLE from each race", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.removeTitleData(i, testTitles[Math.floor(Math.random() * testTitles.length)]);
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(testTitles.length - 1);
      }
    });

    it("Should remove a random ACTIVE PORTRAIT from each race/gender", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.removeActivePortraitIndex(
            gameEnums.genders.findIndex("F"),
            i,
            Math.floor(Math.random() * testFemalePortraits.length)
        );
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("F"),
            i
        )).to.equal(testFemalePortraits.length - 1);
        await knightGeneratorContract.removeActivePortraitIndex(
            gameEnums.genders.findIndex("M"),
            i,
            Math.floor(Math.random() * testMalePortraits.length)
        );
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(testMalePortraits.length - 1);
      }
    });

    // it("Should revert any external calls to generateNewRandomKnight() method from outside Knight contract", async function () {
    //   await expect(knightGeneratorContract.connect(signers[2]).generateNewRandomKnight(100)).to.be.reverted;
    // });

  });

  describe("Knight", function () {
    it(`Should mint ${testKnightAmount} randomly generated NFTs`, async function () {
      let totalAttributeAttempts = 0;
      for (let i = 1;i <= testKnightAmount;i++) {
        const mintTx = await knightContract.connect(signers[1]).mint();
        const mintReceipt = await mintTx.wait();
        expect(await knightContract.ownerOf(i)).to.equal(signers[1].address);
        const mint2Tx = await knightContract.connect(signers[1]).generateKnightInit(i, Math.floor(Math.random() * 10 ** 12));
        const mint2Receipt = await mint2Tx.wait();
        //console.log(mint2Receipt.gasUsed.toNumber());
        // Need to be under 200k gas for VRF
        expect(mint2Receipt.gasUsed.toNumber()).to.be.below(200000);
        let attributeSum = 0;
        let attributeAttempts = 0;
        while (attributeSum !== 84) {
          attributeAttempts++;
          totalAttributeAttempts++;
          const mint3Tx = await knightContract.connect(signers[1]).generateKnightAttributes(i, Math.floor(Math.random() * 10 ** 12));
          const mint3Receipt = await mint3Tx.wait();
          // Need to be under 200k gas for VRF
          expect(mint3Receipt.gasUsed.toNumber()).to.be.below(200000);
          //console.log(attributeAttempts + ": " + mint3Receipt.gasUsed.toNumber());
          const knightAttributes = await knightContract.getAttributes(i);
          let knightAttributesSum = 0;
          for (let i = 0; i < 7; i++) {
            attributeSum += knightAttributes[i];
          }
        }
      }
      //console.log(`Total Attribute Attempts: ${totalAttributeAttempts} avg.: ${totalAttributeAttempts / testKnightAmount}/knight`)
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