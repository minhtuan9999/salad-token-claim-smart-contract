import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  let admin = process.env.ADMIN_ADDRESS as string;
  const urlMetadataItems ="";

  const RegenerationItem= await ethers.getContractFactory("RegenerationItem");
  const regenerationItem = await RegenerationItem.deploy(urlMetadataItems);
  regenerationItem.deployed();
  console.log(`ADDRESS_CONTRACT_REGENERATION_ITEM=${regenerationItem.address}`)
  const RegenFusion= await ethers.getContractFactory("RegenFusionMonster");
  const regenFusion = await RegenFusion.deploy();
  regenFusion.deployed(); 
  // console.log(await regenFusion.encodeOAS(0, "0x48C067bBA30256384c2e3194d282b70bf86C9226", 0, "118027387037952600000", "1716618377"));
  
  // regenerationItem.mintMultipleItem("0x48C067bBA30256384c2e3194d282b70bf86C9226", [0], [1]);
  // await wait();
  console.log(`RegenFusionMonster=${regenFusion.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
