import dotenv from 'dotenv';
dotenv.config();
import { Web3Storage, getFilesFromPath } from 'web3.storage';
import gameEnums from './gameEnums.js';

const baseDir = "../images/processed";


async function main() {
    const client = new Web3Storage({ token: process.env.WEB3STORAGE_TOKEN });
    for (let raceCounter = 0; raceCounter < gameEnums.races.enum.length; raceCounter++) {
        for (let genderIndex = 0;genderIndex < gameEnums.genders.enum.length;genderIndex++) {
            if (gameEnums.races.isMaleOnly(raceCounter) && gameEnums.genders.enum[genderIndex] == "F") {
                continue;
            }
            const portraitFiles = await getFilesFromPath(
                path.join(
                    baseDir,
                    gameEnums.races.enum[raceCounter],
                    gameEnums.genders.enum[genderIndex]
                )
            );
            const cid = await client.put(portraitFiles);
            console.log(gameEnums.races.enum[raceCounter] + " " + gameEnums.genders.enum[genderIndex] + ": " + cid);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });