module.exports = async ({getNamedAccounts, deployments, getChainId}) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = await getChainId();
    // If we are on a local development network, we need to deploy mocks!
    if (chainId == 31337) {
        log("Local network detected! Deploying mocks...");
        const linkToken = await deploy('LinkToken', { from: deployer, log: true })
        await deploy('VRFCoordinatorMock', {
            from: deployer,
            log: true,
            args: [linkToken.address]
        })
    }
}
module.exports.tags = ['all', 'mocks'];