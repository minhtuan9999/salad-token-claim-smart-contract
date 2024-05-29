require('dotenv').config();
const ethers = require('ethers');
const generalABI = require('../artifacts/contracts/GeneralHash/GeneralHash.sol/GeneralHash.json');
const genesisABI = require('../artifacts/contracts/GenesisHash/GenesisHash.sol/GenesisHash.json');


// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet("fe35d2583042c17ec7b84fe5e4a8de81d5b065448c26eb2c0c51a7f4468603ee", provider);

// // Create a wallet using the manager's private key
const contractGeneral = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENERAL, generalABI.abi, managerWallet);
const contractGenesis = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENESIS, genesisABI.abi, managerWallet);


async function main() {
  try {
    const tx1 = (await contractGeneral.getDetailGroup(0));
    // console.log(Number(tx1.totalSupply), Number(tx1.issueAmount));
    // await tx1.wait();
    console.log("Contract Token: DONE ", tx1);
  } catch (error) {
    console.error('Error:', error);
  }
}
main()