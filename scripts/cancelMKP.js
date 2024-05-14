require('dotenv').config();
const ethers = require('ethers');
const marketPlaceABI = require('../artifacts/contracts/MarketPlace/Marketplace.sol/ReMonsterMarketplace.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contract = new ethers.Contract(process.env.ADDRESS_CONTRACT_MARKET, marketPlaceABI.abi, managerWallet);

async function main() {
  try {
    const listSale = await contract.getListSale()
    console.log(11, listSale.length);
    const tx = await contract.cancelMarketItemSale(listSale[0].orderId)
    console.log(11, listSale);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()