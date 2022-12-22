const { contractAddresses } = require("../constants/contractAddresses")
const { verify } = require("./verify")
const { ethers } = require("hardhat");

async function main() {
  const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
  console.log("Deploying BimkonEyes...");
  const args = [contractAddresses.walletAddress, contractAddresses.walletAddress, contractAddresses.walletAddress];
  const bimkonEyes = await BimkonEyes.deploy(...args);
  await bimkonEyes.deployed();
  console.log("BimkonEyes deployed to:", bimkonEyes.address);
  await bimkonEyes.deployTransaction.wait(5)
  await verify(bimkonEyes.address, args)

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });