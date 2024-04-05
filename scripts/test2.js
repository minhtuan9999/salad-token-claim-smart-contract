require('dotenv').config();
const ethers = require('ethers');
const ABI = require('../artifacts/contracts/Coach/Coach.sol/Coach.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contract = new ethers.Contract(process.env.ADDRESS_CONTRACT_COACH, ABI.abi, managerWallet);

async function main() {
  try {
    const tx1 = await contract.setMonsterContract("0xEB684e3f74ddd8E0653D21a17aa429F3e1a420e8");
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()