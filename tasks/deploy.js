const {contractAddresses } = require("../constants/contractAddresses")
const { verify } = require("./verify")
const { ethers } = require("hardhat");

async function main() {
  const SignatureChecker = await ethers.getContractFactory("SignatureChecker");
  console.log("Deploying SignatureChecker...");
  const signatureChecker = await SignatureChecker.deploy();
  console.log("signatureChecker deployed to:", signatureChecker.address);
  await signatureChecker.deployTransaction.wait(2)
  const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
  console.log("Deploying BimkonEyes...");
  const args = [contractAddresses.walletAddress, contractAddresses.walletAddress, contractAddresses.walletAddress, signatureChecker.address];
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