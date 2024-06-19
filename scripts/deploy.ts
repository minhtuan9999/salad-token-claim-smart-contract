import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  // Deploy contract token SALD
  const SaladToken = await ethers.getContractFactory("SaladToken");
  const saladToken = await SaladToken.deploy();
  saladToken.deployed();
  console.log(`SALD_ADDRESS=${saladToken.address}`)

  // Deploy contract claim system
  const ClaimSystem = await ethers.getContractFactory("ClaimSystem");
  const claimSystem = await ClaimSystem.deploy(saladToken.address);
  claimSystem.deployed();
  console.log(`CLAIM_ADDRESS=${claimSystem.address}`)

    // Transfer token SALD
    const txid = await saladToken.transfer(claimSystem.address, "10000000000000000000000000")
    await txid.wait()
    console.log(`Transfer done`)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
