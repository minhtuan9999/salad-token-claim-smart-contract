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
  const tx = await managerGift.giftItem([
    '0x0e60AfffC061614a4159B9C63aD91213A31Fd4Bd',
    '0xC19A84Af102857CcAC53AD0ab4A94692565D8a3a'
  ], [ { collectionItem: 0, typeItem: [ 0 ], amount: [ 1 ] } ])
  tx.wait()
  console.log(1, tx);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
