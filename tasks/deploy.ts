import { ethers } from "hardhat";

async function main() {
    const BimkonEyes = await ethers.getContractFactory("BimkonEyes");
    console.log("Deploying BimkonEyes...");
    const bimkonEyes = await BimkonEyes.deploy('0x62b35Eb73edcb96227F666A878201b2cF915c2B5', '0x62b35Eb73edcb96227F666A878201b2cF915c2B5', '0x62b35Eb73edcb96227F666A878201b2cF915c2B5');
    await bimkonEyes.deployed();
    console.log("BimkonEyes deployed to:",  bimkonEyes.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });