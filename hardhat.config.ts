import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.14",
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    stardust: {
      url: "https://stardust.metis.io/?owner=588",
      chainId: 588,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    metis: {
      url: "https://andromeda.metis.io/?owner=1088",
      chainId: 1088,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      stardust: " ",
      metis: " "
    },
    customChains: [
      {
        network: "stardust",
        chainId: 588,
        urls: {
          apiURL: "https://stardust-explorer.metis.io/api",
          browserURL: "https://stardust-explorer.metis.io/"
        }
      },
      {
        network: "metis",
        chainId: 1088,
        urls: {
          apiURL: "https://andromeda-explorer.metis.io/api",
          browserURL: "https://andromeda-explorer.metis.io/"
        }
      },
    ]
  }
}

export default config;
