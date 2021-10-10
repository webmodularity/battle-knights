// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const deployHelper = require("./deployAddressHelper");
const gameEnums = require("./gameEnums");
const seedNames = require("./seedNames");
const seedTitles = require("./seedTitles");


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
        const maleNames = seedNames[gameEnums.races.enum[raceCounter]]["M"];
        const maleNamesList = [];
        if (maleNames.length > 35) {
            // Split
            while(maleNames.length) {
                maleNamesList.push(maleNames.splice(0,35));
            }
        } else {
            maleNamesList.push(maleNames);
        }
        for (let i = 0;i < maleNamesList.length;i++) {
            await KnightGenerator.connect(deployer).addNameData(
                gameEnums.genders.findIndex("M"),
                raceCounter,
                maleNamesList[i]
            );
        }
        if (!gameEnums.races.isMaleOnly(raceCounter)) {
            const femaleNames = seedNames[gameEnums.races.enum[raceCounter]]["F"];
            const femaleNamesList = [];
            if (femaleNames.length > 35) {
                // Split
                while(femaleNames.length) {
                    femaleNamesList.push(femaleNames.splice(0,35));
                }
            } else {
                femaleNamesList.push(femaleNames);
            }
            for (let i = 0;i < femaleNamesList.length;i++) {
                await KnightGenerator.connect(deployer).addNameData(
                    gameEnums.genders.findIndex("F"),
                    raceCounter,
                    femaleNamesList[i]
                );
            }
        }
        const titles = seedTitles[gameEnums.races.enum[raceCounter]];
        const titlesList = [];
        if (titles.length > 25) {
            // Split
            while(titles.length) {
                titlesList.push(titles.splice(0,25));
            }
        } else {
            titlesList.push(titles);
        }
        for (let i = 0;i < titlesList.length;i++) {
            await KnightGenerator.connect(deployer).addTitleData(raceCounter, titlesList[i]);
        }
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
