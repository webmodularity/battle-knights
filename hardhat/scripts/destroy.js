// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const Knight = await hre.ethers.getContractAt("Knight", "0x01fF43C64D1130d2C851b24e10b4f97f2cc2d650");
    const KnightGenerator = await hre.ethers.getContractAt("KnightGenerator", "0x13cc52DAdA4bcd01a168c19A15A841E1F36B6eD9");
    const {deployer, syncer} = await hre.ethers.getNamedSigners();
    const destroyTx = await Knight.connect(deployer).destroy();
    const destroy2Tx = await KnightGenerator.connect(deployer).destroy();
    console.log("Knight contracts destroyed.");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
