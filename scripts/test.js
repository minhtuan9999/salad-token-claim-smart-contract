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
    const tx1 = await contractRegenFusionMonster.initContractAddress("0xd97dff32D060048adB2388B5fC43EFA17A6D297D","0x49707D090F1dE47bf8db3271d37Cc7fdD9a9965a", "0x1C647363380fC610f5208E334eF331eF9475d542","0x55d5521c8AE92c5421A7bB10865Fb1191a8Af60c","0xEaA2102618628D01bf61BD9F906b710ac97C9187","0x7151cfCe78061809bB3fBBa1D1b40F4c3D19a503", "0x8B32f6e976f2eAc7d16a5437B92752BF02b818d4", "0xEB684e3f74ddd8E0653D21a17aa429F3e1a420e8", "0x3C971ccf2F799EBa65EA25E7461D7Ad438c811aD");
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()