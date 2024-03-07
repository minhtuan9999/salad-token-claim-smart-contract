require('dotenv').config();
const ethers = require('ethers');
const monsterABI = require('../artifacts/contracts/ERC721/Monster/Monster.sol/Monster.json'); // Import the ABI JSON file
const regenFusionABI = require('../artifacts/contracts/ERC721/Monster/RegenAndFusionMonster.sol/RegenFusionMonster.json'); // Import the ABI JSON file
const genesisABI = require('../artifacts/contracts/ERC721/Genersis_Hash.sol/GenesisHash.json');
const generalABI = require('../artifacts/contracts/ERC721/General_Hash.sol/GeneralHash.json');
const accessoriesABI = require('../artifacts/contracts/ERC721/Accessories.sol/Accessories.json');
const coachABI = require('../artifacts/contracts/ERC721/Coach.sol/Coach.json');
const farmABI = require('../artifacts/contracts/ERC721/Farm.sol/ReMonsterFarm.json');
const hashChipABI = require('../artifacts/contracts/ERC721/HashChipNFT/HashChipNFT.sol/HashChipNFT.json');
const crystalABI = require('../artifacts/contracts/ERC721/Monster_Crystal.sol/MonsterCrystal.json');
const memoryABI = require('../artifacts/contracts/ERC721/Monster_Memory.sol/MonsterMemory.json');
const skinABI = require('../artifacts/contracts/ERC721/Skin.sol/Skin.json');

const trainingItemABI = require('../artifacts/contracts/ERC1155/TrainingItem.sol/TrainingItem.json'); 
const ehanceItemABI = require('../artifacts/contracts/ERC1155/EnhanceItem.sol/EhanceItem.json'); 
const fusionItemABI = require('../artifacts/contracts/ERC1155/FusionItem.sol/FusionItem.json'); 
const regenerationItemABI = require('../artifacts/contracts/ERC1155/RegenerationItem.sol/RegenerationItem.json'); 

const marketPlaceABI = require('../artifacts/contracts/Marketplace.sol/ReMonsterMarketplace.json');
const shopABI = require('../artifacts/contracts/Shop.sol/ReMonsterShop.json');
const treasuryABI = require('../artifacts/contracts/TreasuryContract.sol/TreasuryContract.json');

// Create a provider connected to the Ethereum network
const provider = new ethers.providers.JsonRpcProvider(process.env.RPC);
const managerWallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// // Create a wallet using the manager's private key
const contractMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_MONSTER, monsterABI.abi, managerWallet);
const contractRegenFusionMonster = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGEN_FUSION, regenFusionABI.abi, managerWallet);
const contractGenesis = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENESIS, genesisABI.abi, managerWallet);
const contractGeneral = new ethers.Contract(process.env.ADDRESS_CONTRACT_GENERAL, generalABI.abi, managerWallet);
const contractAccessories = new ethers.Contract(process.env.ADDRESS_CONTRACT_ACCESSORIES, accessoriesABI.abi, managerWallet);
const contractCoach = new ethers.Contract(process.env.ADDRESS_CONTRACT_COACH, coachABI.abi, managerWallet);
const contractFarm = new ethers.Contract(process.env.ADDRESS_CONTRACT_FARM, farmABI.abi, managerWallet);
const contractHashChip = new ethers.Contract(process.env.ADDRESS_CONTRACT_HASHCHIP, hashChipABI.abi, managerWallet);
const contractCrystal = new ethers.Contract(process.env.ADDRESS_CONTRACT_CRYSTAL, crystalABI.abi, managerWallet);
const contractMemory = new ethers.Contract(process.env.ADDRESS_CONTRACT_MEMORY, memoryABI.abi, managerWallet);
const contractSkin = new ethers.Contract(process.env.ADDRESS_CONTRACT_SKIN, skinABI.abi, managerWallet);

const contractTrainingItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_TRAINING_ITEM, trainingItemABI.abi, managerWallet);
const contractEhanceItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_ENHANCE_ITEM, ehanceItemABI.abi, managerWallet);
const contractRegenerationItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_REGENERATION_ITEM, regenerationItemABI.abi, managerWallet);
const contractFusionItem = new ethers.Contract(process.env.ADDRESS_CONTRACT_FUSION_ITEM, fusionItemABI.abi, managerWallet);

const contractShop = new ethers.Contract(process.env.ADDRESS_CONTRACT_SHOP, shopABI.abi, managerWallet);
const contractMarketPlace = new ethers.Contract(process.env.ADDRESS_CONTRACT_MARKET, marketPlaceABI.abi, managerWallet);
const contractTreasury = new ethers.Contract(process.env.ADDRESS_CONTRACT_TREASURY, treasuryABI.abi, managerWallet);

async function callMonsterSmartContract() {
  try {
    const MONSTER_ROLE = await contractMonster.MANAGEMENT_ROLE();
    const tx1 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_REGEN_FUSION);
    await tx1.wait();
    // const tx2 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_COACH);
    // await tx2.wait();
    // const tx3 = await contractMonster.grantRole(MONSTER_ROLE, process.env.ADDRESS_CONTRACT_CRYSTAL);
    // await tx3.wait();
    console.log("Monster grantRole: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callRegenFusionMonsterSmartContract() {
  try {
    const tx1 = await contractRegenFusionMonster.initContractAddress(
      process.env.ADDRESS_CONTRACT_TOKEN_XXX,
      process.env.ADDRESS_CONTRACT_GENERAL,
      process.env.ADDRESS_CONTRACT_GENESIS,
      process.env.ADDRESS_CONTRACT_HASHCHIP,
      process.env.ADDRESS_CONTRACT_MEMORY,
      process.env.ADDRESS_CONTRACT_REGENERATION_ITEM,
      process.env.ADDRESS_CONTRACT_FUSION_ITEM,
      process.env.ADDRESS_CONTRACT_MONSTER,
      process.env.ADMIN_ADDRESS,
    );
    await tx1.wait();
    console.log("initContractAddress: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callGenesisHashSmartContract() {
  try {
    // const GENESIS_HASH = await contractGenesis.MANAGEMENT_ROLE();
    // const tx1 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_BRIDGE);
    // await tx1.wait();
    // const tx2 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_MONSTER);
    // await tx2.wait();
    // const tx3 = await contractGenesis.grantRole(GENESIS_HASH, process.env.ADDRESS_CONTRACT_SHOP);
    // await tx3.wait();

    const list = [7,8,9,18,19,20,22,23,24,25,26,42,44];
    setTimeout(async function() {
      for (var i = 0; i < list.length ; i++) {
        const randomNumber = Math.floor(Math.random() * 5) + 1;
        const tx3 = await contractGenesis.setTimesOfRegeneration(0, list[i], randomNumber.toString());
        await tx3.wait();
        console.log("contractGenesis: DONE ");
      } 
    }, 2000);
    

  } catch (error) {
    console.error('Error:', error);
  }
}

// callGenesisHashSmartContract()

async function callGeneralHashSmartContract() {
  try {
    const ROLE = await contractGeneral.MANAGEMENT_ROLE();
    // const tx1 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    // await tx1.wait();
    const tx2 = await contractGeneral.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx2.wait();
    console.log("contractGenesis: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callAccessoriesSmartContract() {
  try {
    const tx1 = await contractAccessories.setMonsterItem(process.env.ADDRESS_CONTRACT_ENHANCE_ITEM);
    await tx1.wait();
    console.log("contractAccessories: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callCoach() {
  try {
    const ROLE = await contractCoach.MANAGEMENT_ROLE();
    const tx1 = await contractCoach.setMonsterContract(process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    const tx2 = await contractCoach.setMonsterMemory(process.env.ADDRESS_CONTRACT_MEMORY);
    await tx2.wait();
    console.log("contractCoach: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callMemory() {
  try {
    const ROLE = await contractMemory.MANAGEMENT_ROLE();
    const tx1 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_COACH);
    await tx1.wait();
    const tx2 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    await tx2.wait();
    const tx3 = await contractMemory.grantRole(ROLE, process.env.ADDRESS_CONTRACT_CRYSTAL);
    await tx3.wait();
    console.log("contractMemory: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callFarm() {
  try {
    const ROLE = await contractFarm.MANAGEMENT_ROLE();
    // const tx1 = await contractFarm.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    // await tx1.wait();
    const tx2 = await contractFarm.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE);
    await tx2.wait();  
    console.log("contracFarm: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callShop() {
  try {
    // const ROLE = await contractShop.MANAGEMENT_ROLE();
    // const tx1 = await contractShop.setGeneralContract(process.env.ADDRESS_CONTRACT_GENERAL);
    // await tx1.wait();
    // const tx2 = await contractShop.setGenesisContract(process.env.ADDRESS_CONTRACT_GENESIS);
    // await tx2.wait();
    // const tx3 = await contractShop.setFarmContract(process.env.ADDRESS_CONTRACT_FARM);
    // await tx3.wait();
    // const tx4 = await contractShop.setTrainingItemContract(process.env.ADDRESS_CONTRACT_TRAINING_ITEM);
    // await tx4.wait();

    const tx5 = await contractShop.initContract(process.env.ADDRESS_CONTRACT_GENERAL, process.env.ADDRESS_CONTRACT_GENESIS,
      process.env.ADDRESS_CONTRACT_FARM, process.env.ADDRESS_CONTRACT_TRAINING_ITEM
      )
    await tx5.wait();
    console.log("contractShop: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}


async function callHashChip() {
  try {
    const ROLE = await contractHashChip.MANAGEMENT_ROLE();
    const tx1 = await contractHashChip.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE);
    await tx1.wait();
    console.log("contractHashChip: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callCrystal() {
  try {
    const ROLE = await contractCrystal.MANAGEMENT_ROLE();
    const tx1 = await contractCrystal.initSetMonsterContract(process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    const tx2 = await contractCrystal.initSetMonsterMemory(process.env.ADDRESS_CONTRACT_MEMORY);
    await tx2.wait();
    console.log("contractCrystal: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callTrainingItem() {
  try {
    const ROLE = await contractTrainingItem.MANAGEMENT_ROLE();
    const tx1 = await contractTrainingItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx1.wait();
    console.log("TrainingItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
const delayBetweenCalls = 5000; 
const executeCalls = async () => {
  await callFarm();
  await new Promise(resolve => setTimeout(resolve, delayBetweenCalls));
  
  await callGeneralHashSmartContract();
  await new Promise(resolve => setTimeout(resolve, delayBetweenCalls));

  await callGenesisHashSmartContract();
  await new Promise(resolve => setTimeout(resolve, delayBetweenCalls));

  await callTrainingItem();
  await new Promise(resolve => setTimeout(resolve, delayBetweenCalls));

  await callShop();
};

// Call the function to start the sequence
// executeCalls();

async function callRegenItem() {
  try {
    const ROLE = await contractRegenerationItem.MANAGEMENT_ROLE();
    const tx1 = await contractRegenerationItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    console.log("contractRegenerationItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callEhanceItem() {
  try {
    const ROLE = await contractEhanceItem.MANAGEMENT_ROLE();
    // const tx1 = await contractEhanceItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_ACCESSORIES);
    // await tx1.wait();
    const tx2 = await contractEhanceItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_BRIDGE);
    await tx2.wait();
    console.log("contractEhanceItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}
async function callFusionItem() {
  try {
    const ROLE = await contractFusionItem.MANAGEMENT_ROLE();
    const tx1 = await contractFusionItem.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MONSTER);
    await tx1.wait();
    console.log("contractFusionItem: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callMarketPlace() {
  try {
    const ROLE = await contractMarketPlace.MANAGEMENT_ROLE();
    const tx1 = await contractMarketPlace.setTreasuryAddress(process.env.ADDRESS_CONTRACT_TREASURY);
    await tx1.wait();
    console.log("contractMarketPlace: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function callTreasury() {
  try {
    const ROLE = await contractTreasury.MANAGEMENT_ROLE();
    const tx1 = await contractTreasury.grantRole(ROLE, process.env.ADDRESS_CONTRACT_MARKET);
    await tx1.wait();
    const tx2 = await contractTreasury.grantRole(ROLE, process.env.ADDRESS_CONTRACT_SHOP);
    await tx2.wait();
    console.log("contractTreasury: DONE ");
  } catch (error) {
    console.error('Error:', error);
  }
}

async function updateMonster() {
  await callMonsterSmartContract();
  await callRegenFusionMonsterSmartContract();
  await callGenesisHashSmartContract();
  await callGeneralHashSmartContract();
  await callCoach();
  await callMemory();
  await callCrystal();
  await callRegenItem();
  await callFusionItem();
}

// updateMonster()

async function mintMonster() {
  const abi = [
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "approved",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Approval",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "ApprovalForAll",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "burn",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_address",
          "type": "address"
        },
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "number",
          "type": "uint256"
        }
      ],
      "name": "createMonster",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_firstId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_lastId",
          "type": "uint256"
        },
        {
          "internalType": "uint256[]",
          "name": "_listItem",
          "type": "uint256[]"
        },
        {
          "internalType": "uint256[]",
          "name": "_amount",
          "type": "uint256[]"
        }
      ],
      "name": "fusionGeneralHash",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_firstId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_lastId",
          "type": "uint256"
        },
        {
          "internalType": "uint256[]",
          "name": "_listItem",
          "type": "uint256[]"
        },
        {
          "internalType": "uint256[]",
          "name": "_amount",
          "type": "uint256[]"
        }
      ],
      "name": "fusionGenesisHash",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_firstTokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_lastTokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256[]",
          "name": "_listItem",
          "type": "uint256[]"
        },
        {
          "internalType": "uint256[]",
          "name": "_amount",
          "type": "uint256[]"
        }
      ],
      "name": "fusionMonsterNFT",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "grantRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "Paused",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "previousAdminRole",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "newAdminRole",
          "type": "bytes32"
        }
      ],
      "name": "RoleAdminChanged",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "sender",
          "type": "address"
        }
      ],
      "name": "RoleGranted",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "sender",
          "type": "address"
        }
      ],
      "name": "RoleRevoked",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Transfer",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "Unpaused",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "burnMonster",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "_address",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        }
      ],
      "name": "createNFTMonster",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "fistId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "lastId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "newTokenId",
          "type": "uint256"
        }
      ],
      "name": "fusionGeneralHashNFT",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "fistId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "lastId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "newTokenId",
          "type": "uint256"
        }
      ],
      "name": "fusionGenesisHashNFT",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_genesisId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_generalId",
          "type": "uint256"
        },
        {
          "internalType": "uint256[]",
          "name": "_listItem",
          "type": "uint256[]"
        },
        {
          "internalType": "uint256[]",
          "name": "_amount",
          "type": "uint256[]"
        }
      ],
      "name": "fusionMultipleHash",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "genesisId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "generalId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "newTokenId",
          "type": "uint256"
        }
      ],
      "name": "fusionMultipleHashNFT",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "newMonster",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "firstTokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "lastTokenId",
          "type": "uint256"
        }
      ],
      "name": "fusionMultipleMonster",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "address",
          "name": "_addressContract",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_chainId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_account",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "_isOAS",
          "type": "bool"
        },
        {
          "internalType": "uint256",
          "name": "_cost",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_deadline",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "_sig",
          "type": "bytes"
        }
      ],
      "name": "mintMonster",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "mintMonsterFree",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_itemId",
          "type": "uint256"
        }
      ],
      "name": "mintMonsterFromRegeneration",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "pause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "_chainId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_addressContract",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "_account",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "_isOAS",
          "type": "bool"
        },
        {
          "internalType": "uint256",
          "name": "_cost",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "_deadline",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "_sig",
          "type": "bytes"
        }
      ],
      "name": "refreshTimesOfRegeneration",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "refreshTimesRegeneration",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "renounceRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "revokeRole",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "data",
          "type": "bytes"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "setApprovalForAll",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "baseURI_",
          "type": "string"
        }
      ],
      "name": "setBaseURI",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "uint256[]",
          "name": "cost",
          "type": "uint256[]"
        }
      ],
      "name": "setCostOfType",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IFusionItem",
          "name": "_fusionItem",
          "type": "address"
        }
      ],
      "name": "setFusionContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IGeneralHash",
          "name": "generalHash",
          "type": "address"
        }
      ],
      "name": "setGeneralHashContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IGenesisHash",
          "name": "genesisHash",
          "type": "address"
        }
      ],
      "name": "setGenesisHashContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IHashChip",
          "name": "hashChip",
          "type": "address"
        }
      ],
      "name": "setHashChipContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "limit",
          "type": "uint256"
        }
      ],
      "name": "setLimitOfType",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IMonsterMemory",
          "name": "_monsterMemory",
          "type": "address"
        }
      ],
      "name": "setMonsterMemoryContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "setNewSeason",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_cost",
          "type": "uint256"
        }
      ],
      "name": "setNftRepair",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract IRegenerationItem",
          "name": "_regenerationItem",
          "type": "address"
        }
      ],
      "name": "setRegenerationContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bool",
          "name": "_status",
          "type": "bool"
        }
      ],
      "name": "setStatusMonster",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "bool",
          "name": "status",
          "type": "bool"
        }
      ],
      "name": "setStatusMonsters",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "contract IToken",
          "name": "_tokenBase",
          "type": "address"
        }
      ],
      "name": "setTokenBaseContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "contract ITreasuryContract",
          "name": "_treasuryContract",
          "type": "address"
        }
      ],
      "name": "setTreasuryContract",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_address",
          "type": "address"
        }
      ],
      "name": "setValidator",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "transferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "unpause",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes",
          "name": "",
          "type": "bytes"
        }
      ],
      "name": "_isSigned",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "_monster",
      "outputs": [
        {
          "internalType": "bool",
          "name": "lifeSpan",
          "type": "bool"
        },
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "typeMint",
          "type": "uint8"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "name": "_realdyFreeNFT",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "_timesRegenExternal",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "balanceOf",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "costOfExternal",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "costOfGeneral",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "costOfGenesis",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "costOfHashChip",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "decimal",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "DEFAULT_ADMIN_ROLE",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "cost",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "chainId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "deadline",
          "type": "uint256"
        }
      ],
      "name": "encodeOAS",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "fusionItem",
      "outputs": [
        {
          "internalType": "contract IFusionItem",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "generalHashContract",
      "outputs": [
        {
          "internalType": "contract IGeneralHash",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "genesisHashContract",
      "outputs": [
        {
          "internalType": "contract IGenesisHash",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "getApproved",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "uint256",
          "name": "_chainId",
          "type": "uint256"
        },
        {
          "internalType": "address",
          "name": "_address",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "getFeeOfTokenId",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "fee",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "_address",
          "type": "address"
        }
      ],
      "name": "getListTokenOfAddress",
      "outputs": [
        {
          "internalType": "uint256[]",
          "name": "",
          "type": "uint256[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        }
      ],
      "name": "getRoleAdmin",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "getStatusMonster",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "hashChipNFTContract",
      "outputs": [
        {
          "internalType": "contract IHashChip",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "role",
          "type": "bytes32"
        },
        {
          "internalType": "address",
          "name": "account",
          "type": "address"
        }
      ],
      "name": "hasRole",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        }
      ],
      "name": "isApprovedForAll",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_tokenId",
          "type": "uint256"
        }
      ],
      "name": "isFreeMonster",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "limitExternal",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "limitGeneral",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "limitGenesis",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "limitHashChip",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "MANAGEMENT_ROLE",
      "outputs": [
        {
          "internalType": "bytes32",
          "name": "",
          "type": "bytes32"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "monsterMemory",
      "outputs": [
        {
          "internalType": "contract IMonsterMemory",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "nftRepair",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ownerOf",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "paused",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "enum MonsterBase.TypeMint",
          "name": "_type",
          "type": "uint8"
        },
        {
          "internalType": "address",
          "name": "_account",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "cost",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "chainId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "deadline",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "signature",
          "type": "bytes"
        }
      ],
      "name": "recoverOAS",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "pure",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "regenerationItem",
      "outputs": [
        {
          "internalType": "contract IRegenerationItem",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "season",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes4",
          "name": "interfaceId",
          "type": "bytes4"
        }
      ],
      "name": "supportsInterface",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "tokenBaseContract",
      "outputs": [
        {
          "internalType": "contract IToken",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "tokenByIndex",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "tokenOfOwnerByIndex",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "tokenURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "totalSupply",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "treasuryContract",
      "outputs": [
        {
          "internalType": "contract ITreasuryContract",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ];
  const address = "0xa8A07B603ECb7252598d96f05c0c588b0D5e0eB0";
  const contract = new ethers.Contract(address, abi, managerWallet);
  for( let i=247; i< 259; i++) {
    const detail = await contract._monster(i);
    const owner = await contract.ownerOf(i);
    let type = 0;
    if(detail.typeMint == 0) {
      type = 1;
    } else if (detail.typeMint == 1) {
      type = 3;
    } else if(detail.typeMint == 2) {
      type = 4;
    } else if(detail.typeMint == 3) {
      type = 5;
    } else if(detail.typeMint == 4) {
      type = 6;
    } else if(detail.typeMint == 5) {
      type = 2;
    } else {
      type = 10;
    }
    await contractMonster.mintMonster(owner.toString(), type);
    console.log(i);
  }
}

async function trainingFarm() {
  try {
    const tx = await contractFarm.trainingMonster(process.env.ADDRESS_CONTRACT_MONSTER, 160, 256);
  await tx.wait();
  } catch (error) {
    console.log(error);
  }
}
