// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const deployHelper = require("./deployAddressHelper");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const Knight = await hre.ethers.getContractAt("Knight", deployHelper.knightAddress);
    const {deployer, syncer} = await hre.ethers.getNamedSigners();
    const mintTx = await Knight.connect(deployer).mint();
    //const mintReceipt = await mintTx.wait();
    //const mintRequestId = mintReceipt.events;
    //console.log(mintRequestId);


    //const knightName = await Knight.getName(1);

    console.log("Knight mint transaction started");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
