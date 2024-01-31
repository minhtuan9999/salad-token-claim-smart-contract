import { ethers } from "hardhat";

async function main() {

  const RegenFusionMonster = await ethers.getContractFactory("RegenFusionMonster");
  const regenFusionMonster = await RegenFusionMonster.deploy();
  regenFusionMonster.deployed();
  // Log results
  console.log(`ADDRESS_CONTRACT_RegenFusionMonster: ${regenFusionMonster.address}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
