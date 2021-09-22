const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Knights", function () {
  let knightContract;
  let signers = [];

  before(async () => {
    signers = await ethers.getSigners();
    const knightFactory = await ethers.getContractFactory("Knight");
    knightContract = await knightFactory.deploy();
    // Wait for contract to deploy
    await knightContract.deployed();
    // Set MINTER_ROLE for signers[1]
    await knightContract.addMinterRole(signers[1].address);
  });

  it("Should mint a new NFT via specialMint() to a signer address", async function () {
    const mintTx = await knightContract.connect(signers[1]).mintSpecial(
        signers[2].address,
        [18, 18, 18, 18, 18, 18, 18],
        "Rory the Rogue",
        "0x" + "M".charCodeAt(0).toString(16),
        "test_ipfs_url"
    );
    await mintTx.wait();
    expect(await knightContract.ownerOf(1)).to.equal(signers[2].address);
  });

  it("Should store attributes on chain for new Knight NFT", async function () {
    const firstKnightAttributes = await knightContract.getKnightAttributes(1);
    for (let i = 0;i < 6;i++) {
      expect(firstKnightAttributes[i]).to.equal(18);
    }
  });

  it("Should store name on chain for new Knight NFT", async function () {
    const firstKnightName = await knightContract.getKnightName(1);
    expect(firstKnightName).to.equal("Rory the Rogue");
  });

  it("Should store gender on chain for new Knight NFT", async function () {
    const firstKnightGender = await knightContract.getKnightGender(1);
    expect(firstKnightGender).to.equal("0x" + "M".charCodeAt(0).toString(16));
  });
});
