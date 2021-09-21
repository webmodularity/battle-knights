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
        "test_ipfs_url"
    );
    await mintTx.wait();
    expect(await knightContract.ownerOf(1)).to.equal(signers[2].address);
  });

  it("Should have stored stats on chain for new Knight NFT (Luck=18)", async function () {
    const firstKnightAttributes = await knightContract.getKnightAttributes(1);
    // Luck should equal 18
    expect(firstKnightAttributes[6]).to.equal(18);
  });

  it("Should have stored name on chain for new Knight NFT (Rory the Rogue)", async function () {
    const firstKnightName = await knightContract.getKnightName(1);
    expect(firstKnightName).to.equal("Rory the Rogue");
  });
});
