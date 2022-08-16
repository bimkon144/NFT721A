import { ethers } from "hardhat";

async function main() {
  const SignatureChecker = await ethers.getContractFactory("SignatureChecker");
  console.log("Deploying SignatureChecker...");
  const signatureChecker = await SignatureChecker.deploy();
  console.log("BimkonEyes deployed to:", signatureChecker.address);
  const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
  console.log("Deploying BimkonEyes...");
  const bimkonEyes = await BimkonEyes.deploy('0xd8B92056223F39FbeDCf08BA05440397B6c68D59', '0xd8B92056223F39FbeDCf08BA05440397B6c68D59', '0xd8B92056223F39FbeDCf08BA05440397B6c68D59', signatureChecker.address);
  await bimkonEyes.deployed();
  console.log("BimkonEyes deployed to:", bimkonEyes.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });