require('dotenv').config();
const ethers = require('ethers');
const regenFusionABI = require('../artifacts/contracts/Monster/regeneration_and_fusion.sol/RegenFusionMonster.json'); // Import the ABI JSON file

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractRegenFusionMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGEN_FUSION, regenFusionABI.abi, managerWallet);

async function main() {
  try {
    const tx1 = await contractRegenFusionMonster.setValidator("0x3C971ccf2F799EBa65EA25E7461D7Ad438c811aD");
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()