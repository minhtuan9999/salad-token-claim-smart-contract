require('dotenv').config();
const ethers = require('ethers');
const monsterABI = require('../artifacts/contracts/Monster/monster.sol/Monster.json'); // Import the ABI JSON file
const coachABI = require('../artifacts/contracts/Coach/Coach.sol/Coach.json');
const memoryABI = require('../artifacts/contracts/MonsterMemory.sol/Monster_Memory.sol/MonsterMemory.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_MONSTER, monsterABI.abi, managerWallet);
const contractCoach = new ethers.Contract(process.env.ADDRESS_CONTRACT_COACH, coachABI.abi, managerWallet);
const contractMemory = new ethers.Contract(process.env.ADDRESS_CONTRACT_MEMORY, memoryABI.abi, managerWallet);

async function callMonsterSmartContract() {
  try {
    // const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    // const tx1 = await contractCoach.setMonsterContract(process.env.ADDRESS_CONTRACT_MONSTER);
    // await tx1.wait();
    // console.log("Monster grantRole: DONE ", tx1);
    // const ROLE = await contractToken.MANAGEMENT_ROLE();
    // const tx1 = await contractToken.grantRole(ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    console.log(await contractMemory.hasRole(await contractMemory.MANAGEMENT_ROLE(),process.env.ADDRESS_CONTRACT_COACH ));
  } catch (error) {
    console.error('Error:', error);
  }
}
callMonsterSmartContract()