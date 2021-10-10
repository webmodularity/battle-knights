import dotenv from 'dotenv';
dotenv.config();
import { Web3Storage, File } from 'web3.storage';
import gameEnums from './gameEnums.js';
import deployHelper from "./deployAddressHelper.js";
//const tokenId = 3;
const client = new Web3Storage({ token: process.env.WEB3STORAGE_TOKEN });

async function main() {

    const Knight = await hre.ethers.getContractAt("Knight", deployHelper.knightAddress);
    //await updateMetdata(tokenId, Knight);
    Knight.on('KnightMinted', async (tokenId) => {
        console.log("Updating metadata for Knight: " + tokenId);
        await updateMetdata(tokenId, Knight);
    });
}

async function updateMetdata(tokenId, knightContract) {
    const knightName = await knightContract.getName(tokenId);
    const knightGender = await knightContract.getGender(tokenId);
    const knightRace = await knightContract.getRace(tokenId);
    const knightAttributes = await  knightContract.getAttributes(tokenId);
    const knightPortraitCid = await knightContract.getPortrait(tokenId);

    const metadata = buildMetadataFile(knightName, knightGender, knightRace, knightAttributes, knightPortraitCid);
    const buffer = Buffer.from(JSON.stringify(metadata));
    const cid = await client.put([new File([buffer], 'metadata.json')]);
    // Update tokenURI on chain
    await knightContract.updateTokenURI(tokenId, "ipfs://" + cid + "/metadata.json");
}

function buildMetadataFile(name, gender, race, attributes, portraitCid) {
    const attributesMetadata = [
        {
            "trait_type": "Race",
            "value": gameEnums.races.enum[race]
        },
        {
            "trait_type": "Gender",
            "value": gameEnums.genders.enum[gender]
        }
    ];
    for (let i = 0;i < gameEnums.attributes.enum.length;i++) {
        attributesMetadata.push({
            "trait_type": gameEnums.attributes.enum[i],
            "display_type": "number",
            "value": attributes[i],
            "max_value": 18
        });
    }
    const descriptionGender = gameEnums.genders.enum[gender] == "M" ? "Male" : "Female";
    return {
        image: 'ipfs://' + portraitCid,
        name: name,
        description: descriptionGender + " " + gameEnums.races.enum[race],
        attributes: attributesMetadata
    };

}

main();