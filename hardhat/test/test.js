const { expect } = require("chai");
const { ethers } = require("hardhat");

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
    // Set some test names and titles
    const maleNamesTx = await knightGeneratorContract.addData('maleNames', ["Rory", "Dan", "Cody", "Phil", "Alvaro"]);
    await maleNamesTx.wait();
    const femaleNamesTx = await knightGeneratorContract.addData('femaleNames', ["Colette", "Celeste", "Ellie", "Eva"]);
    await femaleNamesTx.wait();
    const titlesTx = await knightGeneratorContract.addData('titles', ["the Rogue", "the Patient", "the Viking", "the Crusher"]);
    await titlesTx.wait();
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

    // it("Should log some knights to console", async function () {
    //   for (let i = 1;i <= testKnightAmount;i++) {
    //     const knightName = await knightContract.getName(i);
    //     const knightRace = await knightContract.getRace(i);
    //     const knightGender = await knightContract.getGender(i);
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