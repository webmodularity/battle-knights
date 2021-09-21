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
});
