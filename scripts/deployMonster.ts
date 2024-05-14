import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  const Monster= await ethers.getContractFactory("Monster");
  const monster = await Monster.deploy();
  monster.deployed();
  console.log(`ADDRESS_CONTRACT_MONSTER=${monster.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
