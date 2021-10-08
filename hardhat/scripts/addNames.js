// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const deployHelper = require("./deployAddressHelper");
const gameEnums = require("./gameEnums");
// Test data
const testMaleNames = ["Rory", "Dan", "Cody", "Phil", "Alvaro"];
const testFemaleNames = ["Colette", "Celeste", "Ellie", "Eva"];
const testTitles = ["the Rogue", "the Patient", "the Viking", "the Crusher", "the Tainted", "the Crusader"];

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    const KnightGenerator = await hre.ethers.getContractAt("KnightGenerator", deployHelper.knightGeneratorAddress);
    const {deployer, syncer} = await hre.ethers.getNamedSigners();
    for (let raceCounter = 0;raceCounter < gameEnums.races.enum.length;raceCounter++) {
        await KnightGenerator.connect(deployer).addNameData(gameEnums.genders.findIndex("M"), raceCounter, testMaleNames);
        await KnightGenerator.connect(deployer).addNameData(gameEnums.genders.findIndex("F"), raceCounter, testFemaleNames);
        await KnightGenerator.connect(deployer).addTitleData(raceCounter, testTitles);
    }

    console.log("Knight names/titles seeded to Knight Generator");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
