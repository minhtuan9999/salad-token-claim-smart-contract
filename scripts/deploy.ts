import { ethers } from "hardhat";

async function main() {
  // Config
  const TOTAL_SUPPLY = "100000000000000000000000000000";
  const FEE = "10000000000000000000"; // 10% * 10^18
  const ADDRESS_RECEICE = "0xeC9168A14469B88caC91398a0E22a8Ce9f9A44ed";
  const NAME_FARM = "FARM"
  const SYMBOL_FARM = "FM"

  // Deploy contract token (OAS) 
  const Test20 = await ethers.getContractFactory("Test20");
  const test20 = await Test20.deploy(TOTAL_SUPPLY);
  test20.deployed();

  const Marketplace = await ethers.getContractFactory("ReMonsterMarketplace");
  const marketplace = await Marketplace.deploy(FEE, ADDRESS_RECEICE, test20.address);
  marketplace.deployed();

  const Shop = await ethers.getContractFactory("ReMonsterShop");
  const shop = await Shop.deploy(ADDRESS_RECEICE, test20.address);
  shop.deployed();

  const Farm = await ethers.getContractFactory("FARM");
  const farm = await Farm.deploy(NAME_FARM, SYMBOL_FARM);
  farm.deployed();

  // Set role manager to SHOP
  await farm.grantRole(farm.MANAGERMENT_ROLE(), shop.address)

  // Log results
  console.log(`ADDRESS_CONTRACT_TOKEN: ${test20.address}`);
  console.log(`ADDRESS_CONTRACT_MARKETPLACE: ${marketplace.address}`);
  console.log(`ADDRESS_CONTRACT_SHOP: ${shop.address}`);
  console.log(`ADDRESS_CONTRACT_FARM: ${farm.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
