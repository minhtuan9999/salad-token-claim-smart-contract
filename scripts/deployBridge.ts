import { ethers } from "hardhat";

async function main() {
  let admin = "0x3C971ccf2F799EBa65EA25E7461D7Ad438c811aD";
  let testAddress = "0x926A80dEfCfb7130E02E1BE68fF52354E865d6c8";
  // Deploy contract bridge OAS
  const HashChip= await ethers.getContractFactory("T2WebERC721");
  const hashChip = await HashChip.deploy();
  hashChip.deployed();

  const Bridge= await ethers.getContractFactory("BridgeHashChip");
  const bridge = await Bridge.deploy(hashChip.address);
  bridge.deployed();
  // Log results
  console.log(`ADDRESS_CONTRACT_BRIDGE_POLYGON: ${bridge.address}`)
  console.log(`ADDRESS_CONTRACT_HASHCHIP_POLYGON: ${hashChip.address}`)

  await hashChip.initialize("Re Monster","RMT", "https://zaif.mypinata.cloud/ipfs/QmSRz944Dn2tvShDXo2i8MfYpSJsSaLWWAu3mzv6kpBtJu/1310", 100);
  for(let i = 0; i < 10; i++){
    await hashChip.mint(admin);
  }
  for(let i = 0; i < 10; i++){
    await hashChip.mint(testAddress);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
