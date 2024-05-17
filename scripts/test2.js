require("dotenv").config();
const ethers = require("ethers");
const coachABI = require('../artifacts/contracts/Coach/Coach.sol/Coach.json');
const crystalABI = require('../artifacts/contracts/MonsterCrystal/Monster_Crystal.sol/MonsterCrystal.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractCoach = new ethers.Contract(process.env.ADDRESS_CONTRACT_CRYSTAL, crystalABI.abi, managerWallet);


async function main() {
  try {
    const tx1 = await contractCoach.initSetMonsterContract("0x8E7B8c3D3662A82Ea4560e940170147aCD42099c");
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error("Error:", error);
  }
}
main();
