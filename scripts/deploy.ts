import { ethers } from "hardhat";
require('dotenv').config();

async function main() {
  let admin = process.env.ADMIN_ADDRESS as string;

  const feeSeller = (10 * 10**18).toString();
  const generalPrice = (10**18).toString();
  const genesisPrice = (10**18).toString();
  const farmPrice = (10**18).toString();
  const bitPrice = (10**18).toString();
  const urlMetadataItems ="";

  // Deploy contract token (OAS) 
  ///////////////////////////////////////////////////////////////////////// ERC20 ////////////////////////////////////////////////////////////////////
  const TokenXXX= await ethers.getContractFactory("TokenXXX");
  const tokenXXX = await TokenXXX.deploy("xxx", "xxx");
  tokenXXX.deployed();
  console.log(`ADDRESS_CONTRACT_TOKEN XXX=${tokenXXX.address}`)
  ///////////////////////////////////////////////////////////////////////// END ////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////// ERC1155 ////////////////////////////////////////////////////////////////////
  const TrainingItem= await ethers.getContractFactory("TrainingItem");
  const trainingItem = await TrainingItem.deploy(urlMetadataItems);
  trainingItem.deployed();
  console.log(`ADDRESS_CONTRACT_TRAINING_ITEM=${trainingItem.address}`)
  
  const RegenerationItem= await ethers.getContractFactory("RegenerationItem");
  const regenerationItem = await RegenerationItem.deploy(urlMetadataItems);
  regenerationItem.deployed();
  console.log(`ADDRESS_CONTRACT_REGENERATION_ITEM=${regenerationItem.address}`)
  
  const FusionItem= await ethers.getContractFactory("FusionItem");
  const fusionItem = await FusionItem.deploy(urlMetadataItems);
  fusionItem.deployed();
  console.log(`ADDRESS_CONTRACT_FUSION_ITEM=${fusionItem.address}`)

  const EhanceItem= await ethers.getContractFactory("EhanceItem");
  const ehanceItem = await EhanceItem.deploy("baseURL");
  ehanceItem.deployed();
  console.log(`ADDRESS_CONTRACT_ENHANCE=${ehanceItem.address}`)

  ///////////////////////////////////////////////////////////////////////// END ////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////// ERC721 ////////////////////////////////////////////////////////////////////
  const Accessories = await ethers.getContractFactory("Accessories");
  const accessories = await Accessories.deploy();
  accessories.deployed();
  console.log(`ADDRESS_CONTRACT_ACCESSORIES=${accessories.address}`)

  const Coach = await ethers.getContractFactory("Coach");
  const coach = await Coach.deploy();
  coach.deployed();
  console.log(`ADDRESS_CONTRACT_COACH=${coach.address}`)

  const General = await ethers.getContractFactory("GeneralHash");
  const general = await General.deploy();
  general.deployed();
  console.log(`ADDRESS_CONTRACT_GENERAL=${general.address}`)


  const Genesis= await ethers.getContractFactory("GenesisHash");
  const genesis = await Genesis.deploy();
  genesis.deployed();
  console.log(`ADDRESS_CONTRACT_GENESIS=${genesis.address}`)

  const HashChipNFT= await ethers.getContractFactory("HashChipNFT");
  const hashChipNFT = await HashChipNFT.deploy();
  hashChipNFT.deployed();
  console.log(`ADDRESS_CONTRACT_HASHCHIP_NFT=${hashChipNFT.address}`)

  const MonsterCrystal= await ethers.getContractFactory("MonsterCrystal");
  const monsterCrystal = await MonsterCrystal.deploy();
  monsterCrystal.deployed();
  console.log(`ADDRESS_CONTRACT_MOSNTER_CRYSTAL=${monsterCrystal.address}`)

  const MonsterMemory= await ethers.getContractFactory("MonsterMemory");
  const monsterMemory = await MonsterMemory.deploy();
  monsterMemory.deployed();
  console.log(`ADDRESS_CONTRACT_MONSTER_MEMORY=${monsterMemory.address}`)

  const Skin= await ethers.getContractFactory("Skin");
  const skin = await Skin.deploy();
  skin.deployed();
  console.log(`ADDRESS_CONTRACT_SKIN=${skin.address}`)

  const Monster= await ethers.getContractFactory("Monster");
  const monster = await Monster.deploy();
  monster.deployed();
  console.log(`ADDRESS_CONTRACT_MONSTER=${monster.address}`)

  const ReMonsterFarm= await ethers.getContractFactory("ReMonsterFarm");
  const reMonsterFarm = await ReMonsterFarm.deploy("Farm", "FARM", 5000);
  reMonsterFarm.deployed();
  console.log(`ADDRESS_CONTRACT_FARM=${reMonsterFarm.address}`)

  const Trophies= await ethers.getContractFactory("Trophies");
  const trophies = await Trophies.deploy();
  trophies.deployed();
  console.log(`ADDRESS_CONTRACT_TROPHIES=${trophies.address}`)

  const TrainerLicense= await ethers.getContractFactory("TrainerLicense");
  const trainerLicense = await TrainerLicense.deploy();
  trainerLicense.deployed();
  console.log(`ADDRESS_CONTRACT_TRAINER_LICENSE=${trainerLicense.address}`)

  ///////////////////////////////////////////////////////////////////////// END ////////////////////////////////////////////////////////////////////

  const RegenFusion= await ethers.getContractFactory("RegenFusionMonster");
  const regenFusion = await RegenFusion.deploy();
  regenFusion.deployed(); 
  regenFusion.initContractAddress(tokenXXX.address, general.address, genesis.address, hashChipNFT.address, monsterMemory.address, regenerationItem.address, fusionItem.address, monster.address, admin);

  const Shop= await ethers.getContractFactory("ReMonsterShop");
  const shop = await Shop.deploy();
  shop.deployed();
  console.log(`ADDRESS_CONTRACT_SHOP=${shop.address}`)
  shop.initContract(general.address, genesis.address, reMonsterFarm.address, trainingItem.address);

  const ReMonsterMarketplace= await ethers.getContractFactory("ReMonsterMarketplace");
  const reMonsterMarketplace = await ReMonsterMarketplace.deploy(feeSeller, admin);
  reMonsterMarketplace.deployed();
  console.log(`ADDRESS_CONTRACT_MARKETPLACE=${reMonsterMarketplace.address}`)

  const Pools= await ethers.getContractFactory("PoolsContract");
  const pools = await Pools.deploy();
  pools.deployed();
  console.log(`ADDRESS_CONTRACT_POOLS=${pools.address}`)

  const BridgeOAS= await ethers.getContractFactory("Bridge");
  const bridgeOAS = await BridgeOAS.deploy(
    hashChipNFT.address, 
    genesis.address, 
    reMonsterFarm.address, 
    ehanceItem.address
    );
  bridgeOAS.deployed();
  console.log(`ADDRESS_CONTRACT_BRIDGE=${bridgeOAS.address}`)

  //////////////////////////////////////////////////////////////////////////////////////// FEATURE ///////////////////////////////////////////////////////////////////////////
  // mint marketing general
  await general.claimMaketingBox(admin,0);
  await general.claimMaketingBox(admin,1);
  await general.claimMaketingBox(admin,2);
  await general.claimMaketingBox(admin,3);
  await general.claimMaketingBox(admin,4);
  
  // claim marketing genesis
  await genesis.claimMaketingBox(admin, 0);
  await genesis.claimMaketingBox(admin, 1);
  await genesis.claimMaketingBox(admin, 2);
  await genesis.claimMaketingBox(admin, 3);
  await genesis.claimMaketingBox(admin, 4);

  await genesis.claimMaketingWithType(admin, 0, 0);
  await genesis.claimMaketingWithType(admin, 0, 1);
  await genesis.claimMaketingWithType(admin, 0, 2);
  await genesis.claimMaketingWithType(admin, 0, 3);

  await genesis.claimMaketingWithType(admin, 1, 0);
  await genesis.claimMaketingWithType(admin, 1, 1);
  await genesis.claimMaketingWithType(admin, 1, 2);
  await genesis.claimMaketingWithType(admin, 1, 3);
  
  await genesis.claimMaketingWithType(admin, 2, 0);
  await genesis.claimMaketingWithType(admin, 2, 1);
  await genesis.claimMaketingWithType(admin, 2, 2);
  await genesis.claimMaketingWithType(admin, 2, 3);
  await genesis.claimMaketingWithType(admin, 2, 4);

  await genesis.claimMaketingWithType(admin, 3, 0);
  await genesis.claimMaketingWithType(admin, 3, 1);
  await genesis.claimMaketingWithType(admin, 3, 2);
  await genesis.claimMaketingWithType(admin, 3, 3);

  await genesis.claimMaketingWithType(admin, 4, 0);
  await genesis.claimMaketingWithType(admin, 4, 1);
  await genesis.claimMaketingWithType(admin, 4, 2);
  await genesis.claimMaketingWithType(admin, 4, 3);

  // Accressories
  accessories.setMonsterItem(ehanceItem.address);

  // Coach
  coach.setMonsterContract(monster.address);
  coach.setMonsterMemory(monsterMemory.address);

  // Crystal
  monsterCrystal.initSetMonsterContract(monster.address);
  monsterCrystal.initSetMonsterMemory(monsterMemory.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
