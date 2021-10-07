const {networkConfig} = require('../helper-hardhat-config');
const hre = require("hardhat");

module.exports = async ({getNamedAccounts, deployments, getChainId}) => {
    const {deploy, get, execute} = deployments;
    const {deployer} = await getNamedAccounts();
    const chainId = await getChainId();
    let linkTokenAddress;
    let vrfCoordinatorAddress;

    if (chainId == 31337) {
        const linkToken = await get('LinkToken');
        const VRFCoordinatorMock = await get('VRFCoordinatorMock');
        linkTokenAddress = linkToken.address;
        vrfCoordinatorAddress = VRFCoordinatorMock.address;
    } else {
        linkTokenAddress = networkConfig[chainId]['linkToken']
        vrfCoordinatorAddress = networkConfig[chainId]['vrfCoordinator']
    }
    const keyHash = networkConfig[chainId]['keyHash']
    const fee = networkConfig[chainId]['fee']

    const knight = await deploy('Knight', {
        from: deployer,
        args: [vrfCoordinatorAddress, linkTokenAddress, keyHash, fee],
        log: true
    });

    if (chainId == 31337) {
        // Transfer LINK
        const linkContract = await hre.ethers.getContractAt("LinkToken", linkTokenAddress);
        await linkContract.transfer(knight.address, '200000000000000000000');
    }

    const knightGenerator = await deploy('KnightGenerator', {
        from: deployer,
        args: [knight.address],
        log: true
    });

    // Make the Knight contract aware of the KnightGenerator contract
    await execute("Knight",{from: deployer}, 'changeKnightGeneratorContract', knightGenerator.address);

    // log("Run the following command to fund contract with LINK:");
    // log("npx hardhat fund-link --contract " + knight.address + " --network " + networkConfig[chainId]['name'] + additionalMessage);
    // log("Then run RandomNumberConsumer contract with the following command");
    // log("npx hardhat request-random-number --contract " + knight.address + " --network " + networkConfig[chainId]['name']);
    // log("----------------------------------------------------")
}

module.exports.tags = ['all', 'knight'];