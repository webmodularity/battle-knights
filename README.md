## BattleKnights
A crypto-native auto battler game that lives entirely on the blockchain - from knight creation to tournament simulation. Using Chainlink VRF to provide verifiable randomness to the blockchain we can ensure fairness for all.

#### Deployed - Polygon Mumbai Testnet
- Knight Contract: [0x93bD5353C567da7191210e0Ff3516e74081a2CDB](https://mumbai.polygonscan.com/address/0x93bD5353C567da7191210e0Ff3516e74081a2CDB#code#F19#L1)
- KnightGenerator Contract: [0xF15243905A5D9EDEF1BdA2b706Dbd8B091231A91](https://mumbai.polygonscan.com/address/0xF15243905A5D9EDEF1BdA2b706Dbd8B091231A91#code#F5#L1)

#### Info
- Battle Knights: [Knight info and rules summary](https://github.com/webmodularity/battle-knights/tree/main/hardhat)
- Created at: [ETHOnline 2021 Hackathon](https://showcase.ethglobal.com/ethonline2021/battle-knights)
- Test knight collection: [Opensea Testnet](https://testnets.opensea.io/collection/battle-knights)
- Mint a test Knight: [Polygonscan Contract Write Methods](https://mumbai.polygonscan.com/address/0x93bD5353C567da7191210e0Ff3516e74081a2CDB#writeContract)
- Slides: [Presentation Slides](https://docs.google.com/presentation/d/1U5szhU63aoYLMbzfJJ-toNy7lv1uzc3OxeSnlTJgZTM/edit?usp=sharing)

#### Inspiration
I was inspired to experiment by a [tutorial written by Patrick Collins](https://blog.chain.link/build-deploy-and-sell-your-own-dynamic-nft/) exploring dynamic NFTs. The [D&D NFT repo](https://github.com/PatrickAlphaC/dungeons-and-dragons-nft) was a starting point in which I am trying to iterate from.

#### Roadmap
- Front end
- Custom art
- Tournament implementation
- Tokenomics

#### Art
Placeholder art used for testing licensed for use:

- [RPG Backgrounds 02](https://graphicriver.net/item/rpg-backgrounds-02/31818118)
- [RPG Avatars 01](https://graphicriver.net/item/rpg-avatars-01/25356718)
- [RPG Avatars 03](https://graphicriver.net/item/rpg-avatars-03/32737108)
- [RPG Avatars 04](https://graphicriver.net/item/rpg-avatars-04/33007867)
- [RPG Fantasy Avatars](https://graphicriver.net/item/rpg-fantasy-avatars/28251085)

#### Quickstart
Clone the and install the repo:
```
git clone https://github.com/webmodularity/battle-knights.git
cd battle-knights/hardhat
npm i
```
Deploy to testnets or mainnet:
```
npx hardhat --network localhost deploy
```
OR run a local hardhat node:
```
npx hardhat node
```
Modify deployAddressHelper.js to reflect localhost values:
```
vi scripts/deployAddressHelper.js
```
Do some setup:
```
npx hardhat --network localhost run scripts/addNames.js
npx hardhat --network localhost run scripts/addPortraits.js
```
Run tests:
```
npx hardhat test
```
In a separate terminal launch the oracle:
```
npx hardhat --network localhost run scripts/listenKnightEvents.js
```
Mint:
```
npx hardhat --network localhost run scripts/mint.js
```

