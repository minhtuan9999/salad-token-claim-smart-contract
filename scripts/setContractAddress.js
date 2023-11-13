require('dotenv').config();
const ethers = require('ethers');
const monsterABI = require('../artifacts/contracts/ERC721/Monster/Monster.sol/Monster.json'); // Import the ABI JSON file
const regenFusionABI = require('../artifacts/contracts/ERC721/Monster/RegenAndFusionMonster.sol/RegenFusionMonster.json'); // Import the ABI JSON file

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractMonster = new ethers.Contract(process.env.MONSTER_ADDRESS, monsterABI.abi, managerWallet);
const contractRegenFusionMonster = new ethers.Contract(process.env.REGEN_FUSION_ADDRESS, regenFusionABI.abi, managerWallet);

async function callMonsterSmartContract() {
  try {
    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const tx1 = await contractMonster.grantRole(MONSTER_ROLE, process.env.REGEN_FUSION_ADDRESS);
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
    const tx1 = await contractMonster.initContractAddress(
      process.env.TOKEN_XXX_ADDRESS,
      process.env.GENERAL_HASH_ADDRESS,
      process.env.GENESIS_HASH_ADDRESS,
      process.env.HASH_CHIP_ADDRESS_OAS,
      process.env.ADDRESS_CONTRACT_MEMORY,
      process.env.ADDRESS_CONTRACT_REGENERATION_ITEM,
      process.env.ADDRESS_CONTRACT_FUSION_ITEM,
      process.env.ADDRESS_CONTRACT_TREASURY,
      process.env.MONSTER_ADDRESS,
    );
    await tx1.wait();
    console.log("initContractAddress: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callGenesisHashSmartContract() {
  try {
    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const tx1 = await contractMonster.grantRole(MONSTER_ROLE, process.env.REGEN_FUSION_ADDRESS);
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
