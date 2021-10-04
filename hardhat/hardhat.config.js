require("@nomiclabs/hardhat-waffle");
require('hardhat-deploy');
require("hardhat-deploy-ethers");
//require("@nomiclabs/hardhat-ethers");
require('dotenv').config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {},
    localhost: {},
    mumbai: {
      url: process.env.MUMBAI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true
    },
    polygon: {
      url: process.env.POLYGON_MAINNET_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true
    },
  },
  namedAccounts: {
    deployer: {
      default: 0
    },
    syncer: {
      default: 1
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.6.6"
      },
      {
        version: "0.8.5"
      }
    ]
  },
  mocha: {
    timeout: 100000
  }
};
