require("dotenv").config();
const ethers = require("ethers");
const giftABI = require('../artifacts/contracts/ERC1155/ManagerGift.sol/ManagerGift.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractGift = new ethers.Contract(process.env.ADDRESS_CONTRACT_MANAGER_GIFT, giftABI.abi, managerWallet);


async function main() {
  try {
    const tx = await contractGift.giftItem([
      '0x0e60AfffC061614a4159B9C63aD91213A31Fd4Bd',
      '0xC19A84Af102857CcAC53AD0ab4A94692565D8a3a'
    ], [ { collectionItem: 0, typeItem: [ 0 ], amount: [ 1 ] } ])
    await tx.wait()
    console.log("Contract Token: DONE ", tx);
  } catch (error) {
    console.error("Error:", error);
  }
}
main();
