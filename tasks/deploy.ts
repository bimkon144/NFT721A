import { ethers } from "hardhat";

async function main() {
    const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
    console.log("Deploying BimkonEyes...");
    const bimkonEyes = await BimkonEyes.deploy();
    await bimkonEyes.deployed();
    console.log("BimkonEyes deployed to:",  bimkonEyes.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });