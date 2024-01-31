import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  let admin = process.env.ADMIN_ADDRESS as string;

  const feeSeller = (10 * 10**18).toString();
  const generalPrice = (10**18).toString();
  const genesisPrice = (10**18).toString();
  const farmPrice = (10**18).toString();
  const bitPrice = (10**18).toString();

  // // Deploy contract token (OAS) 
  // const TokenXXX= await ethers.getContractFactory("TokenXXX");
  // const tokenXXX = await TokenXXX.deploy("xxx", "xxx");
  // tokenXXX.deployed();

  // const Treasury= await ethers.getContractFactory("TreasuryContract");
  // const treasury = await Treasury.deploy(tokenXXX.address);
  // treasury.deployed();

  // const Accessories = await ethers.getContractFactory("Accessories");
  // const accessories = await Accessories.deploy();
  // accessories.deployed();

  // const Coach = await ethers.getContractFactory("Coach");
  // const coach = await Coach.deploy();
  // coach.deployed();

  // const General = await ethers.getContractFactory("GeneralHash");
  // const general = await General.deploy();
  // general.deployed();

  // const Genesis= await ethers.getContractFactory("GenesisHash");
  // const genesis = await Genesis.deploy();
  // genesis.deployed();

  // const HashChipNFT= await ethers.getContractFactory("HashChipNFT");
  // const hashChipNFT = await HashChipNFT.deploy();
  // hashChipNFT.deployed();

  // const MonsterCrystal= await ethers.getContractFactory("MonsterCrystal");
  // const monsterCrystal = await MonsterCrystal.deploy();
  // monsterCrystal.deployed();
  
  // const MonsterMemory= await ethers.getContractFactory("MonsterMemory");
  // const monsterMemory = await MonsterMemory.deploy();
  // monsterMemory.deployed();

  // const Skin= await ethers.getContractFactory("Skin");
  // const skin = await Skin.deploy();
  // skin.deployed();

  // const Monster= await ethers.getContractFactory("Monster");
  // const monster = await Monster.deploy();
  // monster.deployed();

  // const Pools= await ethers.getContractFactory("TreasuryPoolsContract");
  // const pools = await Pools.deploy();
  // pools.deployed();
  // console.log(pools.address);
  
  // const TrainingItem= await ethers.getContractFactory("TrainingItem");
  // const trainingItem = await TrainingItem.deploy("baseURL");
  // trainingItem.deployed();
  
  // const RegenerationItem= await ethers.getContractFactory("RegenerationItem");
  // const regenerationItem = await RegenerationItem.deploy("baseURL");
  // regenerationItem.deployed();
  
  // const FusionItem= await ethers.getContractFactory("FusionItem");
  // const fusionItem = await FusionItem.deploy("baseURL");
  // fusionItem.deployed();

  // const EhanceItem= await ethers.getContractFactory("EhanceItem");
  // const ehanceItem = await EhanceItem.deploy("baseURL");
  // ehanceItem.deployed();

  // const ReMonsterFarm= await ethers.getContractFactory("ReMonsterFarm");
  // const reMonsterFarm = await ReMonsterFarm.deploy("Farm", "FARM", 5000);
  // reMonsterFarm.deployed();

  const Shop= await ethers.getContractFactory("ReMonsterShop");
  const shop = await Shop.deploy();
  shop.deployed();

  // const ReMonsterMarketplace= await ethers.getContractFactory("ReMonsterMarketplace");
  // const reMonsterMarketplace = await ReMonsterMarketplace.deploy(feeSeller, treasury.address);
  // reMonsterMarketplace.deployed();

  // const BridgeOAS= await ethers.getContractFactory("Bridge");
  // const bridgeOAS = await BridgeOAS.deploy(hashChipNFT.address, genesis.address, reMonsterFarm.address, ehanceItem.address);
  // bridgeOAS.deployed();

  // const Trophies= await ethers.getContractFactory("Trophies");
  // const trophies = await Trophies.deploy();
  // trophies.deployed();

  // const TrainerLicense= await ethers.getContractFactory("TrainerLicense");
  // const trainerLicense = await TrainerLicense.deploy();
  // trainerLicense.deployed();

  // const RegenFusion= await ethers.getContractFactory("RegenFusionMonster");
  // const regenFusion = await RegenFusion.deploy();
  // regenFusion.deployed();

  // // Log results
  // console.log(`ADDRESS_CONTRACT_ACCESSORIES=${accessories.address}`);
  // console.log(`ADDRESS_CONTRACT_COACH=${coach.address}`);
  // console.log(`ADDRESS_CONTRACT_GENERAL=${general.address}`);
  // console.log(`ADDRESS_CONTRACT_GENESIS=${genesis.address}`)
  // console.log(`ADDRESS_CONTRACT_HASHCHIP=${hashChipNFT.address}`)
  // console.log(`ADDRESS_CONTRACT_CRYSTAL=${monsterCrystal.address}`)
  // console.log(`ADDRESS_CONTRACT_MEMORY=${monsterMemory.address}`)
  // console.log(`ADDRESS_CONTRACT_SKIN=${skin.address}`)
  // console.log(`ADDRESS_CONTRACT_MONSTER=${monster.address}`)
  // console.log(`ADDRESS_CONTRACT_TRAINING_ITEM=${trainingItem.address}`)
  // console.log(`ADDRESS_CONTRACT_REGENERATION_ITEM=${regenerationItem.address}`)
  // console.log(`ADDRESS_CONTRACT_FUSION_ITEM=${fusionItem.address}`)
  // console.log(`ADDRESS_CONTRACT_ENHANCE_ITEM=${ehanceItem.address}`)
  console.log(`ADDRESS_CONTRACT_SHOP=${shop.address}`)
  // console.log(`ADDRESS_CONTRACT_MARKET=${reMonsterMarketplace.address}`)
  // console.log(`ADDRESS_CONTRACT_FARM=${reMonsterFarm.address}`)
  // console.log(`ADDRESS_CONTRACT_TOKEN_XXX=${tokenXXX.address}`)
  // console.log(`ADDRESS_CONTRACT_TREASURY=${treasury.address}`)
  // console.log(`ADDRESS_CONTRACT_BRIDGE=${bridgeOAS.address}`)
  // console.log(`ADDRESS_CONTRACT_TROPHIES=${trophies.address}`)
  // console.log(`ADDRESS_CONTRACT_TRAINER_LICENSE=${trainerLicense.address}`)
  // console.log(`ADDRESS_CONTRACT_REGEN_FUSION=${regenFusion.address}`)

  // // mint marketing general
  // await general.claimMaketingBox(admin,0);
  // await general.claimMaketingBox(admin,1);
  // await general.claimMaketingBox(admin,2);
  // await general.claimMaketingBox(admin,3);
  // await general.claimMaketingBox(admin,4);
  
  // // claim marketing genesis
  // await genesis.claimMaketingBox(admin, 0);
  // await genesis.claimMaketingBox(admin, 1);
  // await genesis.claimMaketingBox(admin, 2);
  // await genesis.claimMaketingBox(admin, 3);
  // await genesis.claimMaketingBox(admin, 4);

  // await genesis.claimMaketingWithType(admin, 0, 0);
  // await genesis.claimMaketingWithType(admin, 0, 1);
  // await genesis.claimMaketingWithType(admin, 0, 2);
  // await genesis.claimMaketingWithType(admin, 0, 3);

  // await genesis.claimMaketingWithType(admin, 1, 0);
  // await genesis.claimMaketingWithType(admin, 1, 1);
  // await genesis.claimMaketingWithType(admin, 1, 2);
  // await genesis.claimMaketingWithType(admin, 1, 3);
  
  // await genesis.claimMaketingWithType(admin, 2, 0);
  // await genesis.claimMaketingWithType(admin, 2, 1);
  // await genesis.claimMaketingWithType(admin, 2, 2);
  // await genesis.claimMaketingWithType(admin, 2, 3);
  // await genesis.claimMaketingWithType(admin, 2, 4);

  // await genesis.claimMaketingWithType(admin, 3, 0);
  // await genesis.claimMaketingWithType(admin, 3, 1);
  // await genesis.claimMaketingWithType(admin, 3, 2);
  // await genesis.claimMaketingWithType(admin, 3, 3);

  // await genesis.claimMaketingWithType(admin, 4, 0);
  // await genesis.claimMaketingWithType(admin, 4, 1);
  // await genesis.claimMaketingWithType(admin, 4, 2);
  // await genesis.claimMaketingWithType(admin, 4, 3);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
