require('dotenv').config();
const ethers = require('ethers');
const regenFusionABI = require('../artifacts/contracts/Monster/regeneration_and_fusion.sol/RegenFusionMonster.json'); // Import the ABI JSON file

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet("fe35d2583042c17ec7b84fe5e4a8de81d5b065448c26eb2c0c51a7f4468603ee", provider);

// // Create a wallet using the manager's private key
const contractRegenFusionMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGEN_FUSION, regenFusionABI.abi, managerWallet);


async function main() {
  try {
    const tx1 = await contractRegenFusionMonster.fusionMonsterNFT("0xE085260EB256c33159b232d4e6feDA2c19E1a934",482, 407,[],[],7, 1);
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()