require('dotenv').config();
const ethers = require('ethers');
const monsterABI = require('../artifacts/contracts/ERC721/Monster/Monster.sol/Monster.json'); // Import the ABI JSON file
const regenFusionABI = require('../artifacts/contracts/ERC721/Monster/RegenAndFusionMonster.sol/RegenFusionMonster.json'); // Import the ABI JSON file
const genesisABI = require('../artifacts/contracts/ERC721/Genersis_Hash.sol/GenesisHash.json');
const generalABI = require('../artifacts/contracts/ERC721/General_Hash.sol/GeneralHash.json');
const accessoriesABI = require('../artifacts/contracts/ERC721/Accessories.sol/Accessories.json');
const coachABI = require('../artifacts/contracts/ERC721/Coach.sol/Coach.json');
const farmABI = require('../artifacts/contracts/ERC721/Farm.sol/ReMonsterFarm.json');
const hashChipABI = require('../artifacts/contracts/ERC721/HashChipNFT/HashChipNFT.sol/HashChipNFT.json');
const crystalABI = require('../artifacts/contracts/ERC721/Monster_Crystal.sol/MonsterCrystal.json');
const memoryABI = require('../artifacts/contracts/ERC721/Monster_Memory.sol/MonsterMemory.json');
const skinABI = require('../artifacts/contracts/ERC721/Skin.sol/Skin.json');

const trainingItemABI = require('../artifacts/contracts/ERC1155/TrainingItem.sol/TrainingItem.json'); 
const ehanceItemABI = require('../artifacts/contracts/ERC1155/EnhanceItem.sol/EhanceItem.json'); 
const fusionItemABI = require('../artifacts/contracts/ERC1155/FusionItem.sol/FusionItem.json'); 
const regenerationItemABI = require('../artifacts/contracts/ERC1155/RegenerationItem.sol/RegenerationItem.json'); 

const marketPlaceABI = require('../artifacts/contracts/Marketplace.sol/ReMonsterMarketplace.json');
const shopABI = require('../artifacts/contracts/Shop.sol/ReMonsterShop.json');
const treasuryABI = require('../artifacts/contracts/TreasuryContract.sol/TreasuryContract.json');

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

async function callMonsterSmartContract() {
  try {
    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const tx1 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    const tx2 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_COACH);
    await tx2.wait();
    const tx3 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_CRYSTAL);
    await tx3.wait();
    console.log("Monster grantRole: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callRegenFusionMonsterSmartContract() {
  try {
    const tx1 = await contractRegenFusionMonster.initContractAddress(
      process.env.ADDRESS_CONTRACT_TOKEN_XXX,
      process.env.ADDRESS_CONTRACT_GENERAL,
      process.env.ADDRESS_CONTRACT_GENESIS,
      process.env.ADDRESS_CONTRACT_HASHCHIP,
      process.env.ADDRESS_CONTRACT_MEMORY,
      process.env.ADDRESS_CONTRACT_REGENERATION_ITEM,
      process.env.ADDRESS_CONTRACT_FUSION_ITEM,
      process.env.ADDRESS_CONTRACT_TREASURY,
      process.env.ADDRESS_CONTRACT_MONSTER,
    );
    await tx1.wait();
    console.log("initContractAddress: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callGenesisHashSmartContract() {
  try {
    const GENESIS_HASH = await contractGenesis.MANAGEMENT_ROLE();
    const tx1 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_BRIDGE);
    await tx1.wait();
    const tx2 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_MONSTER);
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
    const tx1 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    const tx2 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx2.wait();
    console.log("contractGenesis: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callAccessoriesSmartContract() {
  try {
    const tx1 = await contractAccessories.setMonsterItem(process.env.ADDRESS_CONTRACT_ENHANCE_ITEM);
    await tx1.wait();
    console.log("contractAccessories: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callCoach() {
  try {
    const ROLE = await contractCoach.MANAGEMENT_ROLE();
    const tx1 = await contractCoach.setMonsterContract(process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    const tx2 = await contractCoach.setMonsterMemory(process.env.ADDRESS_CONTRACT_MEMORY);
    await tx2.wait();
    console.log("contractCoach: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callMemory() {
  try {
    const ROLE = await contractMemory.MANAGEMENT_ROLE();
    const tx1 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_COACH);
    await tx1.wait();
    const tx2 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
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
    const tx1 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx1.wait();
    const tx2 = await contractMemory.grantRole(ROLE, process.env.BRIDGE_OAS_ADDRESS);
    await tx2.wait();  
    console.log("contractMemory: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callShop() {
  try {
    const ROLE = await contractShop.MANAGEMENT_ROLE();
    const tx1 = await contractShop.setGeneralContract(ROLE, process.env.ADDRESS_CONTRACT_GENERAL);
    await tx1.wait();
    const tx2 = await contractShop.setGenesisContract(ROLE, process.env.ADDRESS_CONTRACT_GENESIS);
    await tx2.wait();
    const tx3 = await contractShop.setFarmContract(ROLE, process.env.ADDRESS_CONTRACT_FARM);
    await tx3.wait();
    const tx4 = await contractShop.setTreasuryContract(ROLE, process.env.ADDRESS_CONTRACT_TREASURY);
    await tx4.wait();
    const tx5 = await contractShop.setTrainingItemContract(ROLE, process.env.ADDRESS_CONTRACT_TRAINING_ITEM);
    await tx5.wait();
    console.log("contractShop: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callHashChip() {
  try {
    const ROLE = await contractHashChip.MANAGEMENT_ROLE();
    const tx1 = await contractHashChip.grantRole(ROLE, process.env.BRIDGE_OAS_ADDRESS);
    await tx1.wait();
    console.log("contractHashChip: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callCrystal() {
  try {
    const ROLE = await contractCrystal.MANAGEMENT_ROLE();
    const tx1 = await contractCrystal.initSetMonsterContract(process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    const tx2 = await contractCrystal.initSetMonsterMemory(process.env.ADDRESS_CONTRACT_MEMORY);
    await tx2.wait();
    console.log("contractCrystal: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callTrainingItem() {
  try {
    const ROLE = await contractTrainingItem.MANAGEMENT_ROLE();
    const tx1 = await contractTrainingItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx1.wait();
    console.log("contractCrystal: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callRegenItem() {
  try {
    const ROLE = await contractRegenerationItem.MANAGEMENT_ROLE();
    const tx1 = await contractRegenerationItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
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
    const tx2 = await contractEhanceItem.grantRole(ROLE, process.env.BRIDGE_OAS_ADDRESS);
    await tx2.wait();
    console.log("contractEhanceItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callFusionItem() {
  try {
    const ROLE = await contractFusionItem.MANAGEMENT_ROLE();
    const tx1 = await contractFusionItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    console.log("contractFusionItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callMarketPlace() {
  try {
    const ROLE = await contractMarketPlace.MANAGEMENT_ROLE();
    const tx1 = await contractMarketPlace.setTreasuryAddress(process.env.ADDRESS_CONTRACT_TREASURY);
    await tx1.wait();
    console.log("contractMarketPlace: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callTreasury() {
  try {
    const ROLE = await contractTreasury.MANAGEMENT_ROLE();
    const tx1 = await contractTreasury.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MARKET);
    await tx1.wait();
    const tx2 = await contractTreasury.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx2.wait();
    console.log("contractTreasury: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function updateMonster() {
  await callMonsterSmartContract();
  await callRegenFusionMonsterSmartContract();
  await callGenesisHashSmartContract();
  await callGeneralHashSmartContract();
  await callCoach();
  await callMemory();
  await callCrystal();
  await callRegenItem();
  await callFusionItem();
}

updateMonster()