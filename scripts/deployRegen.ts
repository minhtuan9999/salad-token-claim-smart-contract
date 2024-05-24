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
  // regenFusion.initContractAddress(tokenXXX.address, general.address, genesis.address, hashChipNFT.address, monsterMemory.address, regenerationItem.address, fusionItem.address, monster.address, admin);
  // await wait();
  console.log(`RegenFusionMonster=${regenFusion.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
