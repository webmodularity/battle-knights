// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const deployHelper = require("./deployAddressHelper");
const gameEnums = require("./gameEnums");
const seedPortraits = require("./seedPortraits");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    const Knight = await hre.ethers.getContractAt("Knight", deployHelper.knightAddress);
    const {deployer, syncer} = await hre.ethers.getNamedSigners();
    for (let raceCounter = 0;raceCounter < gameEnums.races.enum.length;raceCounter++) {
        const malePortraits = seedPortraits[gameEnums.races.enum[raceCounter]]["M"];
        const malePortraitsList = [];
        if (malePortraits.length > 15) {
            // Split
            while(malePortraits.length) {
                malePortraitsList.push(malePortraits.splice(0,15));
            }
        } else {
            malePortraitsList.push(malePortraits);
        }
        for (let i = 0;i < malePortraitsList.length;i++) {
            await Knight.connect(deployer).addPortraitData(
                gameEnums.genders.findIndex("M"),
                raceCounter,
                malePortraitsList[i]
            );
        }
        if (!gameEnums.races.isMaleOnly(raceCounter)) {
            const femalePortraits = seedPortraits[gameEnums.races.enum[raceCounter]]["F"];
            const femalePortraitsList = [];
            if (femalePortraits.length > 15) {
                // Split
                while(femalePortraits.length) {
                    femalePortraitsList.push(femalePortraits.splice(0,15));
                }
            } else {
                femalePortraitsList.push(femalePortraits);
            }
            for (let i = 0;i < femalePortraitsList.length;i++) {
                await Knight.connect(deployer).addPortraitData(
                    gameEnums.genders.findIndex("F"),
                    raceCounter,
                    femalePortraitsList[i]
                );
            }
        }
    }

    console.log("Knight portraits seeded to Knight");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
