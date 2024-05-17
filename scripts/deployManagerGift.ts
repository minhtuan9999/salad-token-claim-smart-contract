import { ethers } from "hardhat";
require("dotenv").config();

async function main() {
  const ManagerGift = await ethers.getContractFactory("ManagerGift");
  const managerGift = await ManagerGift.deploy(
    process.env.ADDRESS_CONTRACT_TRAINING_ITEM,
    process.env.ADDRESS_CONTRACT_ENHANCE_ITEM,
    process.env.ADDRESS_CONTRACT_FUSION_ITEM,
    process.env.ADDRESS_CONTRACT_REGENERATION_ITEM
  );
  managerGift.deployed();
  console.log(`ADDRESS_CONTRACT_MANAGER_GIFT=${managerGift.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
