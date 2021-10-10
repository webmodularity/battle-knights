// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const deployHelper = require("./deployAddressHelper");
const tokenId = 1;

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const Knight = await hre.ethers.getContractAt("Knight", deployHelper.knightAddress);
    const KnightGenerator = await hre.ethers.getContractAt("KnightGenerator", deployHelper.knightGeneratorAddress);
    // const {deployer, syncer} = await hre.ethers.getNamedSigners();
    // const mintTx = await Knight.connect(deployer).mint();
    //const mintReceipt = await mintTx.wait();
    //const mintRequestId = mintReceipt.events;
    //console.log(mintRequestId);


    const knightName = await Knight.getName(tokenId);
    const knightGender = await Knight.getGender(tokenId);
    const knightRace = await Knight.getRace(tokenId);
    const knightAttributes = await  Knight.getAttributes(tokenId);

    console.log("Name: " + knightName);
    console.log("Gender: " + knightGender);
    console.log("Race: " + knightRace);
    console.log("Attributes: " + knightAttributes);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
