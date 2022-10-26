import * as dotenv from 'dotenv';

import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-waffle';
import '@nomiclabs/hardhat-ethers'
import '@typechain/hardhat';
import 'hardhat-gas-reporter';
import 'solidity-coverage';


dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    },
    compilers: [
      {
        version: '0.8.10',
      },
      {
        version: '0.8.13',
      }
    ]
  },
  paths: {
    artifacts: './frontend/src/artifacts'
  },
  networks: {
    hardhat: {
      mining: {
        auto: true,
        // interval: 1000
      },
      forking: {
        url: "https://eth-goerli.g.alchemy.com/v2/Kx81tSIBMp3e-odF2je1s2x0yQK8yA8Z",
        blockNumber: 7350643
      }
    },
    testnet: {
      url: process.env.MORALIS_URL,
      accounts: process.env.WALLET_KEY !== undefined
        ? [process.env.WALLET_KEY]
        : []
      //moralis api for deploy/verify on testnet
    },
    bscMainnet: {
      url: process.env.MORALIS_MAIN_URL,
      accounts: { mnemonic: process.env.MNEMONIC }
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL || '',
      accounts:
        process.env.WALLET_KEY !== undefined
          ? [process.env.WALLET_KEY]
          : []
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL || '',
      accounts:
        process.env.WALLET_KEY !== undefined
          ? [process.env.WALLET_KEY]
          : []
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD'
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};

export default config;
