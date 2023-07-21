import { ethers } from "hardhat";

async function main() {
  let admin = "0x3E32A4DDb6072D5E93E45Ca98049bd5b8e6B4E79";
  
  const generalLimitGroup = [320,320,400,320,320];
  const generalGroupA= [100,100,100,100];
  const generalGroupB = [100,100,100,100];
  const generalGroupC = [100,100,100,100,100];
  const generalGroupD = [100,100,100,100];
  const generalGroupE = [100,100,100,100];

  const genesisLimitGroup = [600,600,750,600,600];
  const genesisGroupA= [200,200,200,200];
  const genesisGroupB = [200,200,200,200];
  const genesisGroupC = [200,200,200,200,200];
  const genesisGroupD = [200,200,200,200];
  const genesisGroupE = [200,200,200,200];

  const listGeneralGroup = [generalGroupA,generalGroupB,generalGroupC,generalGroupD, generalGroupE];
  const listGenesisGroup = [genesisGroupA,genesisGroupB,genesisGroupC,genesisGroupD, genesisGroupE];

  // Deploy contract token (OAS) 
  const Accessories = await ethers.getContractFactory("Accessories");
  const accessories = await Accessories.deploy();
  accessories.deployed();

  const Coach = await ethers.getContractFactory("Coach");
  const coach = await Coach.deploy();
  coach.deployed();

  const General = await ethers.getContractFactory("GeneralHash");
  const general = await General.deploy();
  general.deployed();

  const Genesis= await ethers.getContractFactory("GenesisHash");
  const genesis = await Genesis.deploy();
  general.deployed();

  const HashChipNFT= await ethers.getContractFactory("HashChipNFT");
  const hashChipNFT = await HashChipNFT.deploy();
  hashChipNFT.deployed();

  const MonsterCrystal= await ethers.getContractFactory("MonsterCrystal");
  const monsterCrystal = await MonsterCrystal.deploy();
  monsterCrystal.deployed();
  
  const MonsterMemory= await ethers.getContractFactory("MonsterMemory");
  const monsterMemory = await MonsterMemory.deploy();
  monsterMemory.deployed();

  const Skin= await ethers.getContractFactory("Skin");
  const skin = await Skin.deploy();
  skin.deployed();

  const Monster= await ethers.getContractFactory("Monster");
  const monster = await Monster.deploy();
  monster.deployed();

  const RemonsterItem= await ethers.getContractFactory("RemonsterItem");
  const item = await RemonsterItem.deploy("baseURL");
  item.deployed();
  
  // Log results
  console.log(`ADDRESS_CONTRACT_ACCESSORIES: ${accessories.address}`);
  console.log(`ADDRESS_CONTRACT_COACH: ${coach.address}`);
  console.log(`ADDRESS_CONTRACT_GENERAL: ${general.address}`);
  console.log(`ADDRESS_CONTRACT_GENESIS: ${genesis.address}`)
  console.log(`ADDRESS_CONTRACT_HASHCHIP: ${hashChipNFT.address}`)
  console.log(`ADDRESS_CONTRACT_CRYSTAL: ${monsterCrystal.address}`)
  console.log(`ADDRESS_CONTRACT_MEMORY: ${monsterMemory.address}`)
  console.log(`ADDRESS_CONTRACT_SKIN: ${skin.address}`)
  console.log(`ADDRESS_CONTRACT_MONSTER: ${monster.address}`)
  console.log(`ADDRESS_CONTRACT_ITEM: ${item.address}`)

  // Set init contract Accessories
  await accessories.setMonsterItem(item.address);
  // Set init contract Coach
  await coach.setMonsterContract(monster.address);
  await coach.setMonsterMemory(monsterMemory.address);
  /* Set init contract Genesis Hash*/
  // Set detail limit group
  for(let i=0; i< genesisLimitGroup.length; i++){
    await genesis.initSetDetailGroup(i+1, genesisLimitGroup[i]);
  }
  // Set detail specie group A
  for(let i=0; i< genesisLimitGroup.length; i++){
    for(let j=0;j < listGenesisGroup[i].length; j++) {
      await genesis.initSetSpecieDetail(i+1,j+1, listGeneralGroup[i][j]);
    }
  }
  //set validator
  await genesis.initSetValidator(admin);
  /* Set init contract General Hash*/
  // Set detail limit group
  for(let i=0; i< generalLimitGroup.length; i++){
    await general.initSetDetailGroup(i+1, generalLimitGroup[i]);
  }
  // Set detail specie group A
  for(let i=0; i< generalLimitGroup.length; i++){
    for(let j=0;j < listGeneralGroup[i].length; j++) {
      await general.initSetSpecieDetail(i+1,j+1, listGeneralGroup[i][j]);
    }
  }  
  //set validator
  await general.initSetValidator(admin);

  /* Set init contract Monster crystal*/
  await monsterCrystal.initSetMonsterContract(monster.address);
  await monsterCrystal.initSetMonsterMemory(monsterMemory.address);
  await monster.grantRole(monster.MANAGEMENT_ROLE(), monsterCrystal.address);
  await monsterMemory.grantRole(monsterMemory.MANAGEMENT_ROLE(), monsterCrystal.address);

  // Set init contract Memory
  await monsterMemory.grantRole(monsterMemory.MANAGEMENT_ROLE(), coach.address);
  await monsterMemory.grantRole(monsterMemory.MANAGEMENT_ROLE(), monster.address);
  await monsterMemory.grantRole(monsterMemory.MANAGEMENT_ROLE(), monsterCrystal.address);

  // Set init contract Monster
  await monster.grantRole(monster.MANAGEMENT_ROLE(), coach.address);
  await monster.grantRole(monster.MANAGEMENT_ROLE(), monsterCrystal.address);
  await monster.initSetTokenBaseContract(monsterCrystal.address);
  await monster.initSetExternalContract(monsterCrystal.address);
  await monster.initSetGeneralHashContract(general.address);
  await monster.initSetGenesisHashContract(genesis.address);
  await monster.initSetHashChipContract(hashChipNFT.address);
  await monster.initSetMonsterMemoryContract(monsterMemory.address);
  await monster.initSetMonsterItemContract(item.address);
  await monster.initSetTreasuryAdress(item.address);
  // Set init contract General
  await general.grantRole(general.MANAGEMENT_ROLE(), monster.address);
  // Set init contract Genesis
  await genesis.grantRole(genesis.MANAGEMENT_ROLE(), monster.address);
  // Set init contract Item
  await item.grantRole(item.MANAGEMENT_ROLE(), monster.address);
  // Set init contract HashChip
  await hashChipNFT.grantRole(hashChipNFT.MANAGEMENT_ROLE(), monster.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
