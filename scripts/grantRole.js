require('dotenv').config();
const ethers = require('ethers');
const monsterABI = require('../artifacts/contracts/Monster/monster.sol/Monster.json'); // Import the ABI JSON file
const regenFusionABI = require('../artifacts/contracts/Monster/regeneration_and_fusion.sol/RegenFusionMonster.json'); // Import the ABI JSON file
const genesisABI = require('../artifacts/contracts/GenesisHash/GenesisHash.sol/GenesisHash.json');
const generalABI = require('../artifacts/contracts/GeneralHash/GeneralHash.sol/GeneralHash.json');
const accessoriesABI = require('../artifacts/contracts/Accessories/Accessories.sol/Accessories.json');
const coachABI = require('../artifacts/contracts/Coach/Coach.sol/Coach.json');
const farmABI = require('../artifacts/contracts/Farm/Farm.sol/ReMonsterFarm.json');
const hashChipABI = require('../artifacts/contracts/HashChipNFT/HashChipNFT.sol/HashChipNFT.json');
const crystalABI = require('../artifacts/contracts/MonsterCrystal/Monster_Crystal.sol/MonsterCrystal.json');
const memoryABI = require('../artifacts/contracts/MonsterMemory.sol/Monster_Memory.sol/MonsterMemory.json');
const skinABI = require('../artifacts/contracts/Skin/Skin.sol/Skin.json');

const trainingItemABI = require('../artifacts/contracts/ERC1155/TrainingItem.sol/TrainingItem.json'); 
const ehanceItemABI = require('../artifacts/contracts/ERC1155/EnhanceItem.sol/EhanceItem.json'); 
const fusionItemABI = require('../artifacts/contracts/ERC1155/FusionItem.sol/FusionItem.json'); 
const regenerationItemABI = require('../artifacts/contracts/ERC1155/RegenerationItem.sol/RegenerationItem.json'); 

const marketPlaceABI = require('../artifacts/contracts/MarketPlace/Marketplace.sol/ReMonsterMarketplace.json');
const shopABI = require('../artifacts/contracts/Shop/Shop.sol/ReMonsterShop.json');
const treasuryABI = require('../artifacts/contracts/Pools/Pools.sol/PoolsContract.json');
const tokenABI = require('../artifacts/contracts/TokenXXX/tokenxxx.sol/TokenXXX.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_MONSTER, monsterABI.abi, managerWallet);
const contractRegenFusionMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGEN_FUSION, regenFusionABI.abi, managerWallet);
const contractGenesis = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENESIS, genesisABI.abi, managerWallet);
const contractGeneral = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENERAL, generalABI.abi, managerWallet);
const contractAccessories = new ethers.Contract(process.env.ADDRESS_CONTRACT_ACCESSORIES, accessoriesABI.abi, managerWallet);
const contractCoach = new ethers.Contract(process.env.ADDRESS_CONTRACT_COACH, coachABI.abi, managerWallet);
const contractFarm = new ethers.Contract(process.env.ADDRESS_CONTRACT_FARM, farmABI.abi, managerWallet);
const contractHashChip = new ethers.Contract(process.env.ADDRESS_CONTRACT_HASHCHIP, hashChipABI.abi, managerWallet);
const contractCrystal = new ethers.Contract(process.env.ADDRESS_CONTRACT_CRYSTAL, crystalABI.abi, managerWallet);
const contractMemory = new ethers.Contract(process.env.ADDRESS_CONTRACT_MEMORY, memoryABI.abi, managerWallet);
const contractSkin = new ethers.Contract(process.env.ADDRESS_CONTRACT_SKIN, skinABI.abi, managerWallet);

const contractTrainingItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_TRAINING_ITEM, trainingItemABI.abi, managerWallet);
const contractEhanceItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_ENHANCE_ITEM, ehanceItemABI.abi, managerWallet);
const contractRegenerationItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGENERATION_ITEM, regenerationItemABI.abi, managerWallet);
const contractFusionItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_FUSION_ITEM, fusionItemABI.abi, managerWallet);

const contractShop = new ethers.Contract(process.env.ADDRESS_CONTRACT_SHOP, shopABI.abi, managerWallet);
const contractMarketPlace = new ethers.Contract(process.env.ADDRESS_CONTRACT_MARKET, marketPlaceABI.abi, managerWallet);
const contractTreasury = new ethers.Contract(process.env.ADDRESS_CONTRACT_TREASURY, treasuryABI.abi, managerWallet);

const contractToken = new ethers.Contract(process.env.ADDRESS_CONTRACT_TOKEN_XXX, tokenABI.abi, managerWallet);

async function callTokenSmartContract() {
  try {
    const ROLE = await contractToken.MANAGEMENT_ROLE();
    const tx1 = await contractToken.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    const tx2 = await contractToken.grantRole(ROLE, process.env.ADDRESS_CONTRACT_GUILD);
    await tx2.wait();

    console.log("Contract Token: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callMonsterSmartContract() {
  try {
    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const tx1 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    // const tx2 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_COACH);
    // await tx2.wait();
    // const tx3 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_CRYSTAL);
    // await tx3.wait();
    console.log("Monster grantRole: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callGenesisHashSmartContract() {
  try {
    const GENESIS_HASH = await contractGenesis.MANAGEMENT_ROLE();
    const tx1 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_BRIDGE_OAS);
    await tx1.wait();
    const tx2 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx2.wait();
    const tx3 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_SHOP);
    await tx3.wait();
    console.log("contractGenesis: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callGeneralHashSmartContract() {
  try {
    const ROLE = await contractGeneral.MANAGEMENT_ROLE();
    const tx1 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    const tx2 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx2.wait();
    console.log("contractGenesis: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callMemory() {
  try {
    const ROLE = await contractMemory.MANAGEMENT_ROLE();
    const tx1 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_COACH);
    await tx1.wait();
    const tx2 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx2.wait();
    const tx3 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_CRYSTAL);
    await tx3.wait();
    console.log("contractMemory: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callFarm() {
  try {
    const ROLE = await contractFarm.MANAGEMENT_ROLE();
    const tx1 = await contractFarm.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx1.wait();
    const tx2 = await contractFarm.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE_OAS);
    await tx2.wait();  
    console.log("contracFarm: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callHashChipNFT() {
  try {
    const ROLE = await contractHashChip.MANAGEMENT_ROLE();
    const tx1 = await contractHashChip.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE_OAS);
    await tx1.wait();
    console.log("contractHashChip: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callTrainingItem() {
  try {
    const ROLE = await contractTrainingItem.MANAGEMENT_ROLE();
    const tx1 = await contractTrainingItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx1.wait();
    console.log("TrainingItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callRegenItem() {
  try {
    const ROLE = await contractRegenerationItem.MANAGEMENT_ROLE();
    const tx1 = await contractRegenerationItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    console.log("contractRegenerationItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callEhanceItem() {
  try {
    const ROLE = await contractEhanceItem.MANAGEMENT_ROLE();
    const tx1 = await contractEhanceItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_ACCESSORIES);
    await tx1.wait();
    const tx2 = await contractEhanceItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE_OAS);
    await tx2.wait();
    console.log("contractEhanceItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callFusionItem() {
  try {
    const ROLE = await contractFusionItem.MANAGEMENT_ROLE();
    const tx1 = await contractFusionItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    console.log("contractFusionItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function RegenFusion() {
  try {
    const tx1 = await contractRegenFusionMonster.initContractAddress(
      process.env.ADDRESS_CONTRACT_TOKEN_XXX,
      process.env.ADDRESS_CONTRACT_GENERAL,
      process.env.ADDRESS_CONTRACT_GENESIS,
      process.env.ADDRESS_CONTRACT_HASHCHIP,
      process.env.ADDRESS_CONTRACT_MEMORY,
      process.env.ADDRESS_CONTRACT_REGENERATION_ITEM,
      process.env.ADDRESS_CONTRACT_FUSION_ITEM,
      process.env.ADDRESS_CONTRACT_MONSTER,
      process.env.ADMIN_ADDRESS,
    );
    await tx1.wait();

    const tokenRole = await contractToken.MANAGEMENT_ROLE();
    const txToken = await contractToken.grantRole(tokenRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txToken.wait();

    const generalRole = await contractGeneral.MANAGEMENT_ROLE();
    const txGeneral = await contractGeneral.grantRole(generalRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txGeneral.wait();

    const genesisRole = await contractGenesis.MANAGEMENT_ROLE();
    const txGenesis = await contractGenesis.grantRole(genesisRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txGenesis.wait();

    const hashchipRole = await contractHashChip.MANAGEMENT_ROLE();
    const txhashchip= await contractHashChip.grantRole(hashchipRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txhashchip.wait();

    const memeoryRole = await contractMemory.MANAGEMENT_ROLE();
    const txmemory = await contractMemory.grantRole(memeoryRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txmemory.wait();

    const regenitemRole = await contractRegenerationItem.MANAGEMENT_ROLE();
    const txRegenItem = await contractRegenerationItem.grantRole(regenitemRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txRegenItem.wait();

    const fusionRole = await contractFusionItem.MANAGEMENT_ROLE();
    const txFusion = await contractFusionItem.grantRole(fusionRole, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txFusion.wait();

    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const txMonster = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await txMonster.wait();
    console.log("RegenFusion: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
const delayBetweenCalls = 1000;
const functionsToCall = [
  RegenFusion,
  callMonsterSmartContract,
  callGenesisHashSmartContract,
  callGeneralHashSmartContract,
  callMemory,
  callFarm,
  callHashChipNFT,
  callTrainingItem,
  callRegenItem,
  callEhanceItem,
  callFusionItem,
  callTokenSmartContract
];

const executeCalls = async () => {
  for (const fn of functionsToCall) {
    await fn();
    await new Promise(resolve => setTimeout(resolve, delayBetweenCalls));
  }
};

executeCalls()
