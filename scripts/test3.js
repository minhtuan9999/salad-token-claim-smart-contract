require('dotenv').config();
const ethers = require('ethers');
const ABI = require('../artifacts/contracts/Monster/monster.sol/Monster.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contract = new ethers.Contract(process.env.ADDRESS_CONTRACT_MONSTER, ABI.abi, managerWallet);

async function main() {
  try {
    const tx1 = await contract.burn(4);
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()