require("dotenv").config();
const ethers = require("ethers");
const shopABI = require('../artifacts/contracts/Shop/Shop.sol/ReMonsterShop.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractShop = new ethers.Contract(process.env.ADDRESS_CONTRACT_SHOP, shopABI.abi, managerWallet);


async function main() {
  try {
    const tx1 = await contractShop.mintTrainingItem("0x48C067bBA30256384c2e3194d282b70bf86C9226", 11, 1);
    await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error("Error:", error);
  }
}
main();
