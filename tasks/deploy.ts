import { ethers } from "hardhat";

async function main() {
    const MultiSenderV1 = await ethers.getContractFactory("MultiSenderV1");
    console.log("Deploying MultiSenderV1...");
    const multiSenderV1 = await MultiSenderV1.deploy();
    await multiSenderV1.deployed();
    console.log("MultiSenderV1 deployed to:", multiSenderV1.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });