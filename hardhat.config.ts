import * as dotenv from 'dotenv';

import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-etherscan';
import '@openzeppelin/hardhat-upgrades';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'hardhat-gas-reporter';
import 'solidity-coverage';


dotenv.config();

const config: HardhatUserConfig = {
  solidity: '0.8.10',
  paths: {
    artifacts: './frontend/src/artifacts'
  },
  networks: {
    hardhat: {
      mining: {
        auto: true,
        // interval: 1000
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
    }
    // ropsten: {
    //   url: process.env.ROPSTEN_URL || '',
    //   accounts:
    //     process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY !== undefined
    //       ? [process.env.TEST_ETH_ACCOUNT_PRIVATE_KEY]
    //       : []
    // }
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
