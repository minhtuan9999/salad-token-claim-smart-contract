import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  let admin = process.env.ADMIN_ADDRESS as string;
  let hashChipPolygonAddress = "0x926A80dEfCfb7130E02E1BE68fF52354E865d6c8";

  const Bridge= await ethers.getContractFactory("BridgeHashChip");
  const bridge = await Bridge.deploy(hashChipPolygonAddress);
  bridge.deployed();
  console.log(`ADDRESS_CONTRACT_BRIDGE_POLYGON: ${bridge.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
