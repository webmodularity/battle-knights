const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const gameEnums = require("./gameEnums");

const baseDir = "../images";
// Resize
const resize = true;
const desiredImageSize = 256;
// Counters
let processedCounter = 0;
let resizedCounter = 0;

async function main() {
    for (let raceCounter = 0; raceCounter < gameEnums.races.enum.length; raceCounter++) {
        let resizeCounter = 0;
        const dirs = {
            "M": path.join(baseDir, gameEnums.races.enum[raceCounter], "M"),
            "F": path.join(baseDir, gameEnums.races.enum[raceCounter], "F")
        };
        const portraits = {
            "M": fs.readdirSync(dirs["M"]),
            "F": gameEnums.races.isMaleOnly(raceCounter) ? [] : fs.readdirSync(dirs["F"])
        };
        const portraitCounter = {
            "M": 0,
            "F": 0
        };
        for (let genderIndex = 0;genderIndex < gameEnums.genders.enum.length;genderIndex++) {
            if (gameEnums.races.isMaleOnly() && gameEnums.genders.enum[genderIndex] == "F") {
                continue;
            }
            const outputDir = path.join(
                baseDir,
                'processed',
                gameEnums.races.enum[raceCounter],
                gameEnums.genders.enum[genderIndex]
            );
            // Portraits
            for (let i = 0; i < portraits[gameEnums.genders.enum[genderIndex]].length; i++) {
                processedCounter++;
                const imgPath = path.join(
                    dirs[gameEnums.genders.enum[genderIndex]],
                    portraits[gameEnums.genders.enum[genderIndex]][i]
                );
                const img = sharp(imgPath);
                const imgData = await img.metadata();
                if (imgData.format != "png") {
                    continue;
                }
                portraitCounter[gameEnums.genders.enum[genderIndex]]++;
                const outputFilename = buildOutputFilename(
                    gameEnums.races.enum[raceCounter],
                    gameEnums.genders.enum[genderIndex],
                    portraitCounter[gameEnums.genders.enum[genderIndex]],
                    "png"
                );
                if (resize && imgData.width != desiredImageSize) {
                    await img.resize({width: desiredImageSize}).toFile(path.join(outputDir, outputFilename));
                    resizedCounter++;
                } else {
                    fs.copyFileSync(imgPath, path.join(outputDir, outputFilename));
                }
            }
        }
    }
    console.log(`Processed: ${processedCounter} images.`);
    console.log(`Resized: ${resizedCounter} images.`);
}

function buildOutputFilename(raceString, genderString, counter, fileType) {
    return [raceString, genderString, counter].join("_") + "." + fileType;
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });