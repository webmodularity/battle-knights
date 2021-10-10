import dotenv from 'dotenv';
dotenv.config();
import { Web3Storage } from 'web3.storage';
import gameEnums from './gameEnums.js';

const archiveCids = {
    "Human": {
        "M": "bafybeihf2vwy2yvez67hnjsuk5u36ls3xvlwqna7cbjjcgxiewdyovzvvq",
        "F": "bafybeig75tnqcqo7pr2kwwsvpzgf2ipb5mxjpm4nwbwkia7qa24tgkzfhi"
    },
    "Dwarf": {
        "M": "bafybeif6dgl44sipggzsobrbsc5kmhrvh3qumvn7kfgbokwp3v3amyxb3a",
        "F": "bafybeibsfy6dacrt7e7rm4x7izouuglbmswafmnahwbmm2aw47qgvk4csm"
    },
    "Orc": {
        "M": "bafybeihukuaihvh7s4p6hibidco4wxlhhamw6uzqdjgugz3c4iruu557sm",
        "F": "bafybeigm3gdude3kmb27xtbc5dtzcmkwg7lzjjti7h4fhgftsmokcdg2te"
    },
    "Ogre": {
        "M": "bafybeidg5lgcklnj3bbnrajnvkplb6klivrhydh2vrh3htqpfozc67abli"
    },
    "Elf": {
        "M": "bafybeihc4smumwfdqwvmc2j46prxvt3rpfepytvhtmyslvbii2tjpqkhx4",
        "F": "bafybeicf4yrdl4jbkkowl45ubmigquex4ob46iyx34r6ilmlmsnfcjvaqq"
    },
    "Halfling": {
        "M": "bafybeifxz72mah6kxwjwevzekjm2pvvlimvd2jm2od3k2kwwmntjbpaaga",
        "F": "bafybeiahibsli3fffyrdanff6syt3nevr22g2ke5koet6tttt3ntuwcgs4"
    },
    "Undead": {
        "M": "bafybeigkbbukedy4nu7ejntlm7s5xxulpinpdwuva4zox3caam4gzlzp3y"
    },
    "Gnome": {
        "M": "bafybeiekw5e6aordbxad5p4vvu4ifrtf2ogiawypreyrimegi2tbep4n2y",
        "F": "bafybeib34x3icwl5ftam74icq7rzoemcxip6wwcjuyvmgkomxkgwxf3azy"
    }
};

async function main() {
    const client = new Web3Storage({ token: process.env.WEB3STORAGE_TOKEN });
    for (let raceCounter = 0; raceCounter < gameEnums.races.enum.length; raceCounter++) {
        for (let genderIndex = 0;genderIndex < gameEnums.genders.enum.length;genderIndex++) {
            if (gameEnums.races.isMaleOnly(raceCounter) && gameEnums.genders.enum[genderIndex] == "F") {
                continue;
            }
            const archiveCid = archiveCids[gameEnums.races.enum[raceCounter]][gameEnums.genders.enum[genderIndex]];
            const response = await client.get(archiveCid);
            if (!response.ok) {
                throw new Error(`Failed to get ${archiveCid} - [${response.status}] ${response.statusText}`)
            }
            const portraitImages = await response.files();
            console.log(portraitImages);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });