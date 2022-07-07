# BimkonEyes MFT-721A

## Description

this is implementation of NFT-721A

## Demo 


## Contribution

### Installation and run

- git clone 

- cd BimkonEyes
- ```npm i```
- create morallis bsct testnet server
- create .env based on .env.example and your wallet key, mnemonic , moralis URL, etherscan key, 

- run to deploy ```npx hardhat run tasks/deploy.ts --network testnet```
- run verify ```npx hardhat  verify --network testnet "putDeployedAddress"```
- put your deployed address to the variable multiSendContractAddress in CsvContainer.tsx

- cd frontend
- ```npm i```
- ```npm start```


### Managing

cd frontend scripts:

* Run project  - ```npm start```
* Run build  - ```npm run build```
* Run deploy  - ```npm run deploy```

cd MultiSenderV1 scripts:

* Run localhost tests  - ```npx hardhat test```
* Run hardhat clean  - ```npx hardhat clean```
* Run forked bsc mainnet - ```npx hardhat node --fork https://bsc-dataseed.binance.org/```
* Run forked bsc testnet```npx hardhat node --fork https://bsc-dataseed.binance.org/```
