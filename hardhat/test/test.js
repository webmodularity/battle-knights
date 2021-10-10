const { expect } = require("chai");
const { ethers } = require("hardhat");

const gameEnums = require("../scripts/gameEnums");
const seedNames = require("../scripts/seedNames");
const seedTitles = require("../scripts/seedTitles");
const seedPortraits = require("../scripts/seedPortraits");

let knightContract, knightGeneratorContract, linkToken, vrfCoordinatorMock;
const testKnightAmount = 1;

describe("Battle Knights", function () {
  before(async () => {
    await deployments.fixture(['mocks', 'knight']);
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
            seedNames[gameEnums.races.enum[i]]["M"]
        );
        if (!gameEnums.races.isMaleOnly(i)) {
          await knightGeneratorContract.addNameData(
              gameEnums.genders.findIndex("F"),
              i,
              seedNames[gameEnums.races.enum[i]]["F"]
          );
        }
        await knightGeneratorContract.addTitleData(i, seedTitles[gameEnums.races.enum[i]]);
        await knightContract.addPortraitData(
            gameEnums.genders.findIndex("M"),
            i,
            seedPortraits[gameEnums.races.enum[i]]["M"]
        );
        if (!gameEnums.races.isMaleOnly(i)) {
          await knightContract.addPortraitData(
              gameEnums.genders.findIndex("F"),
              i,
              seedPortraits[gameEnums.races.enum[i]]["F"]
          );
        }
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(seedNames[gameEnums.races.enum[i]]["M"].length);
        if (!gameEnums.races.isMaleOnly(i)) {
          expect(await knightGeneratorContract.getNamesCount(
              gameEnums.genders.findIndex("F"),
              i
          )).to.equal(seedNames[gameEnums.races.enum[i]]["F"].length);
        }
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(seedTitles[gameEnums.races.enum[i]].length);
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(seedPortraits[gameEnums.races.enum[i]]["M"].length);
        if (!gameEnums.races.isMaleOnly(i)) {
          expect(await knightGeneratorContract.getActivePortraitsCount(
              gameEnums.genders.findIndex("F"),
              i
          )).to.equal(seedPortraits[gameEnums.races.enum[i]]["F"].length);
        }
      }
    });

    it("Should remove a random NAME from each race/gender", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        if (!gameEnums.races.isMaleOnly(i)) {
          await knightGeneratorContract.removeNameData(
              gameEnums.genders.findIndex("F"),
              i,
              seedNames[gameEnums.races.enum[i]]["F"][Math.floor(Math.random() * seedNames[gameEnums.races.enum[i]]["F"].length)]
          );
          expect(await knightGeneratorContract.getNamesCount(
              gameEnums.genders.findIndex("F"),
              i
          )).to.equal(seedNames[gameEnums.races.enum[i]]["F"].length - 1);
        }
        await knightGeneratorContract.removeNameData(
            gameEnums.genders.findIndex("M"),
            i,
            seedNames[gameEnums.races.enum[i]]["M"][Math.floor(Math.random() * seedNames[gameEnums.races.enum[i]]["M"].length)]);
        expect(await knightGeneratorContract.getNamesCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(seedNames[gameEnums.races.enum[i]]["M"].length - 1);
      }
    });

    it("Should remove a random TITLE from each race", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        await knightGeneratorContract.removeTitleData(i, seedTitles[gameEnums.races.enum[i]][Math.floor(Math.random() * seedTitles[gameEnums.races.enum[i]].length)]);
        expect(await knightGeneratorContract.getTitlesCount(i)).to.equal(seedTitles[gameEnums.races.enum[i]].length - 1);
      }
    });

    it("Should remove a random ACTIVE PORTRAIT from each race/gender", async function () {
      for (let i = 0;i < gameEnums.races.enum.length;i++) {
        if (!gameEnums.races.isMaleOnly(i)) {
          await knightGeneratorContract.removeActivePortraitIndex(
              gameEnums.genders.findIndex("F"),
              i,
              Math.floor(Math.random() * seedPortraits[gameEnums.races.enum[i]]["F"].length)
          );
          expect(await knightGeneratorContract.getActivePortraitsCount(
              gameEnums.genders.findIndex("F"),
              i
          )).to.equal(seedPortraits[gameEnums.races.enum[i]]["F"].length - 1);
        }
        await knightGeneratorContract.removeActivePortraitIndex(
            gameEnums.genders.findIndex("M"),
            i,
            Math.floor(Math.random() * seedPortraits[gameEnums.races.enum[i]]["M"].length)
        );
        expect(await knightGeneratorContract.getActivePortraitsCount(
            gameEnums.genders.findIndex("M"),
            i
        )).to.equal(seedPortraits[gameEnums.races.enum[i]]["M"].length - 1);
      }
    });

    it("Should revert any external calls to this contract from outside Knight contract", async function () {
      await expect(knightGeneratorContract.randomKnightInit(1)).to.be.reverted;
      await expect(knightGeneratorContract.randomKnightAttributes(1)).to.be.reverted;
    });

  });

  describe("Knight", function () {
    it(`Should mint ${testKnightAmount} randomly generated NFTs`, async function () {
      const {deployer, syncer} = await ethers.getNamedSigners();
      for (let i = 1;i <= testKnightAmount;i++) {
        const mintTx = await knightContract.connect(syncer).mint();
        const mintReceipt = await mintTx.wait();
        const mintRequestId = mintReceipt.events[4].data;
        const initTx = await vrfCoordinatorMock.callBackWithRandomness(mintRequestId, Math.floor(Math.random() * 10 ** 12), knightContract.address);
        const initTxReceipt = await initTx.wait();
        if (initTxReceipt.events.length < 3) {
          // TODO BUG: sometimes no events are emitted from initTx, only happens on local tests
          console.log("Skipping..." + i);
          // console.log(initTxReceipt);
          // console.log(initTxReceipt.events);
          // console.log(mintRequestId);
          continue;
        }
        const initTxRequestId = initTxReceipt.events[3].data;
        let attributesTxRequestId = initTxRequestId;
        let attributeAttempts = 0;
        while (attributeAttempts < 7) {
          attributeAttempts++;
          const attributesTx = await vrfCoordinatorMock.callBackWithRandomness(attributesTxRequestId, Math.floor(Math.random() * 10 ** 12), knightContract.address);
          const attributesTxReceipt = await attributesTx.wait();
          if (attributesTxReceipt.events.length <= 1) {
            // Attributes were in range
            break;
          }
          attributesTxRequestId = attributesTxReceipt.events[3].data;
        }
        expect(await knightContract.ownerOf(i)).to.equal(syncer.address);
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

    it("Should store portrait IPFS cid on chain", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightPortraitCid = await knightContract.getPortrait(i);
        expect(knightPortraitCid).to.not.be.empty;
      }
    });

    it("Should not be dead", async function () {
      for (let i = 1;i <= testKnightAmount;i++) {
        const knightIsDead = await knightContract.getIsDead(i);
        expect(knightIsDead).to.be.false;
      }
    });

    it("Token URI should be updatable", async function () {
      await knightContract.updateTokenURI(1, "test-token-uri");
      expect(await knightContract.tokenURI(1)).to.equal("test-token-uri");
    });

    it("Contract should be pausable and revert all transfers while paused", async function () {
      const {deployer, syncer} = await ethers.getNamedSigners();
      const pauseTx = await knightContract.connect(deployer).togglePause();
      // Try mint
      await expect(knightContract.mint()).to.be.reverted;
      // Try transfer
      await expect(knightContract.connect(syncer).transferFrom(
          deployer.address,
          syncer.address,
          1
      )).to.be.reverted;
      // Try burn
      await expect(knightContract.connect(syncer).burn(1)).to.be.reverted;
      const unpauseTx = await knightContract.connect(deployer).togglePause();
      expect(await knightContract.totalSupply()).to.equal(testKnightAmount);
    });

    it("Should burn 1 knight", async function () {
      const {deployer, syncer} = await ethers.getNamedSigners();
      const burnTx = await knightContract.connect(syncer).burn(1);
      expect(await knightContract.totalSupply()).to.equal(testKnightAmount - 1);
    });

    // it("Should log some knights to console", async function () {
    //   for (let i = 2;i <= testKnightAmount - 1;i++) {
    //     const knightName = await knightContract.getName(i);
    //     const knightRace = gameEnums.races.enum[await knightContract.getRace(i)];
    //     const knightGender = gameEnums.genders.enum[await knightContract.getGender(i)];
    //     const knightAttributes = await knightContract.getAttributes(i);
    //     console.log(`${knightName} ${knightGender} ${knightRace}`);
    //     console.log(`${knightAttributes[0]}, ${knightAttributes[1]}, ${knightAttributes[2]}, ${knightAttributes[3]}, ${knightAttributes[4]}, ${knightAttributes[5]}, ${knightAttributes[6]}`);
    //   }
    // });

  });

});