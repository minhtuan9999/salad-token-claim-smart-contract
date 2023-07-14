import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { utils } from "ethers";

describe("Monster Managerment", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    // type 0: EXTERNAL_NFT
    // type 1: GENESIS_HASH
    // type 2: GENERAL_HASH
    // type 3: HASH_CHIP_NFT
    // type 4: REGENERATION_ITEM
    // type 5: FREE
    enum TypeMint {
        EXTERNAL_NFT,
        GENESIS_HASH,
        GENERAL_HASH,
        HASH_CHIP_NFT,
        REGENERATION_ITEM,
        FREE,
        FUSION
    }
    const provider = ethers.provider;
    const cost = 1000;
    async function signMessage(signer: Signer, message: string): Promise<string> {
        const signature = await signer.signMessage(utils.arrayify(message));
        return signature;
    }
    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress, treasuryAddress] = await ethers.getSigners();

        const Accessories = await ethers.getContractFactory("Accessories");
        const accessories = await Accessories.connect(owner).deploy();
        accessories.deployed();

        const Coach = await ethers.getContractFactory("Coach");
        const coach = await Coach.connect(owner).deploy();
        coach.deployed();

        const GeneralHash = await ethers.getContractFactory("GeneralHash");
        const generalHash = await GeneralHash.connect(owner).deploy();
        generalHash.deployed();

        const GenesisHash = await ethers.getContractFactory("GenesisHash");
        const genesisHash = await GenesisHash.connect(owner).deploy();
        genesisHash.deployed();

        const MonsterCrystal = await ethers.getContractFactory("MonsterCrystal");
        const monsterCrystal = await MonsterCrystal.connect(owner).deploy();
        monsterCrystal.deployed();

        const MonsterMemory = await ethers.getContractFactory("MonsterMemory");
        const monsterMemory = await MonsterMemory.connect(owner).deploy();
        monsterMemory.deployed();

        const Monster = await ethers.getContractFactory("Monster");
        const monster = await Monster.connect(owner).deploy();
        monster.deployed();

        const Skin = await ethers.getContractFactory("Skin");
        const skin = await Skin.connect(owner).deploy();
        skin.deployed();

        const RemonsterItem = await ethers.getContractFactory("RemonsterItem");
        const remonsterItem = await RemonsterItem.connect(owner).deploy("https://example.com/");
        remonsterItem.deployed();

        const TokenXXX = await ethers.getContractFactory("TokenXXX");
        const tokenXXX = await TokenXXX.connect(owner).deploy("XXX", "XXX");
        tokenXXX.deployed();

        const ExternalNFT = await ethers.getContractFactory("Test721");
        const externalNFT = await ExternalNFT.connect(owner).deploy();
        externalNFT.deployed();

        const HashChipNFT = await ethers.getContractFactory("HashChipNFT");
        const hashChip = await HashChipNFT.connect(owner).deploy();
        hashChip.deployed();

        return { hashChip, accessories, coach, monster, monsterCrystal, monsterMemory, generalHash, genesisHash, skin, owner, userAddress, remonsterItem, tokenXXX, externalNFT, treasuryAddress };
    }

    // describe("Deployment", function () {
    //     it('should deploy and set the owner correctly', async function () {
    //         const { monster, owner } = await loadFixture(deployERC721Fixture);
    //         expect(await monster.owner()).to.equal(owner.address);
    //     });
    // })
    // describe("Mint from  Free NFT", function () {
    //     it('Should check function: mint NFT Free', async function () {
    //         const { monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);
    //         await expect(monster.connect(owner).mintMonsterFree()).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonsterFree()).to.be.revertedWith("Monster:::MonsterCore::_fromFreeNFT: You have created free NFT");
    //     });
    //     it('Should check event: mint NFT Free', async function () {
    //         const { monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);
    //         let tx1 = await monster.connect(userAddress).mintMonsterFree();
    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(userAddress).ownerOf(token1)).to.equals(userAddress.address);
    //     });
    // })

    // describe("Mint from EXTERNAL NFT", async function () {
    //     it('Should check function: mint EXTERNAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const externalUse = 2;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, externalNFT, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetExternalContract(externalNFT.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.EXTERNAL_NFT,cost,externalUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_fromExternalNFT: Exceed the allowed number of times");
    //     });                
    //     it('Should check refreshTimesOfRegeneration', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const externalUse = 2;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, externalNFT, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetExternalContract(externalNFT.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.EXTERNAL_NFT,cost,externalUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         await expect( monster.connect(owner).refreshTimesOfRegeneration(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_refreshTimesOfRegeneration: Item being used");
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);
    //         await expect( monster.connect(owner).refreshTimesOfRegeneration(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //     });

    //     it('Should check event: mint EXTERNAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const externalUse = 2;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, externalNFT, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetExternalContract(externalNFT.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.EXTERNAL_NFT,cost,externalUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.EXTERNAL_NFT,externalUse, false ,cost,timestamp+1000000, signature);

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //     });
    // })

    // describe("Mint from GENERAL NFT", async function () {
    //     it('Should check function: mint GENERAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, generalHash, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetGeneralHashContract(generalHash.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);

    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let generalRole = await generalHash.connect(owner).MANAGEMENT_ROLE();
    //         await generalHash.connect(owner).initSetDetailGroup(1, 100);
    //         await generalHash.connect(owner).createNFT(owner.address, 1);
    //         await generalHash.connect(owner).grantRole(generalRole,monster.address );

    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.GENERAL_HASH,cost,tokenUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         await expect(monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;

    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_fromGeneralHash: Exceed the allowed number of times");
    //     }); 

    //     it('Should check event: mint GENERAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, generalHash, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetGeneralHashContract(generalHash.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);

    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let generalRole = await generalHash.connect(owner).MANAGEMENT_ROLE();
    //         await generalHash.connect(owner).initSetDetailGroup(1, 100);
    //         await generalHash.connect(owner).createNFT(owner.address, 1);
    //         await generalHash.connect(owner).grantRole(generalRole,monster.address );


    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.GENERAL_HASH,cost,tokenUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         let balance = await generalHash.connect(owner).balanceOf(owner.address);
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENERAL_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;

    //         expect(await generalHash.connect(owner).balanceOf(owner.address)).to.equals(balance.toNumber() - 1);

    //     }); 
    // })

    // describe("Mint GENESIS NFT", async function () {
    //     it('Should check function: mint GENESIS NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, owner, tokenXXX, genesisHash, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetGenesisHashContract(genesisHash.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);

    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let genesisRole = await genesisHash.connect(owner).MANAGEMENT_ROLE();
    //         await genesisHash.connect(owner).initSetDetailGroup(1, 100);
    //         await genesisHash.connect(owner).createNFT(owner.address, 1);
    //         await genesisHash.connect(owner).grantRole(genesisRole,monster.address );

    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.GENESIS_HASH,cost,tokenUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         await expect(monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;

    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_fromGenesisHash: Exceed the allowed number of times");
    //     }); 

    //     it('Should check event: mint GENERAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, owner, tokenXXX, genesisHash, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetGenesisHashContract(genesisHash.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);

    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let genesisRole = await genesisHash.connect(owner).MANAGEMENT_ROLE();
    //         await genesisHash.connect(owner).initSetDetailGroup(1, 100);
    //         await genesisHash.connect(owner).createNFT(owner.address, 1);
    //         await genesisHash.connect(owner).grantRole(genesisRole,monster.address );

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.GENESIS_HASH,cost,tokenUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //     }); 
    //     it('Should check refreshTimesOfRegeneration', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, owner, userAddress, tokenXXX, genesisHash, treasuryAddress} = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetGenesisHashContract(genesisHash.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);

    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address );

    //         let genesisRole = await genesisHash.connect(owner).MANAGEMENT_ROLE();
    //         await genesisHash.connect(owner).initSetDetailGroup(1, 100);
    //         await genesisHash.connect(owner).createNFT(owner.address, 1);
    //         await genesisHash.connect(owner).grantRole(genesisRole,monster.address );

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.GENESIS_HASH,cost,tokenUse,chainId,timestamp+1000000);
    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         let season = await monster.connect(owner).season();
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         await expect( monster.connect(owner).mintMonster(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_fromGenesisHash: Exceed the allowed number of times");
    //         let limit = await monster.connect(owner).limitGenesis();
    //         let balance1 = await monster.connect(owner)._numberOfRegenerations(season, TypeMint.GENESIS_HASH,tokenUse )
    //         await expect(monster.connect(owner).refreshTimesOfRegeneration(TypeMint.GENESIS_HASH,tokenUse, false ,cost,timestamp+1000000, signature)).not.to.be.reverted;
    //         let balance2 = await monster.connect(owner)._numberOfRegenerations(season, TypeMint.GENESIS_HASH,tokenUse )
    //         expect(balance2).to.equals(limit.toNumber() - balance1.toNumber());
    //     }); 
    // })

    // describe("Mint from Hash Chip NFT", async function () {
    //     it('Should check function: mint Hash Chip NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, hashChip, treasuryAddress } = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetHashChipContract(hashChip.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

    //         await hashChip.connect(owner).createNFT(owner.address, 0);
    //         await hashChip.connect(owner).createNFT(owner.address, 1);
    //         await hashChip.connect(owner).createNFT(owner.address, 2);

    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.HASH_CHIP_NFT, cost, tokenUse, chainId, timestamp + 1000000);

    //         const signature = await signMessage(owner, sig.toString());

    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;

    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_fromHashChipNFT: Exceed the allowed number of times");
    //     });
    //     it('Should check refreshTimesOfRegeneration', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, hashChip, treasuryAddress } = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetHashChipContract(hashChip.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

    //         await hashChip.connect(owner).createNFT(owner.address, 0);
    //         await hashChip.connect(owner).createNFT(owner.address, 1);
    //         await hashChip.connect(owner).createNFT(owner.address, 2);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.HASH_CHIP_NFT, cost, tokenUse, chainId, timestamp + 1000000);

    //         const signature = await signMessage(owner, sig.toString());

    //         await expect(monster.connect(owner).refreshTimesOfRegeneration(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).to.be.revertedWith("Monster:::MonsterCore::_refreshTimesOfRegeneration: Item being used");
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         let balance = await tokenXXX.connect(owner).balanceOf(owner.address);
    //         await expect(monster.connect(owner).refreshTimesOfRegeneration(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         expect((await tokenXXX.connect(owner.address).balanceOf(owner.address)).toString()).to.equals((balance.toNumber() - cost).toString());
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature)).not.to.be.reverted;

    //     });

    //     it('Should check event: mint EXTERNAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, hashChip, treasuryAddress } = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetHashChipContract(hashChip.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

    //         await hashChip.connect(owner).createNFT(owner.address, 0);
    //         await hashChip.connect(owner).createNFT(owner.address, 1);
    //         await hashChip.connect(owner).createNFT(owner.address, 2);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.HASH_CHIP_NFT, cost, tokenUse, chainId, timestamp + 1000000);

    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature);

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //     });
    // })

    // describe("Mint from Regeneration NFT ", async function () {
    //     it('Should check function: mint Regeneration NFT', async function () {
    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, remonsterItem, treasuryAddress } = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetRegenerationContract(remonsterItem.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

    //         let number = 3;

    //         let itemRole = await remonsterItem.connect(owner).MANAGEMENT_ROLE();
    //         await remonsterItem.connect(owner).grantRole(itemRole, monster.address);

    //         let tx1 = await remonsterItem.connect(owner).mint(owner.address,1,1,number,"0x32");

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "mintMonsterItems");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.itemId.toString();
    //             }
    //         }
    //         let balance1 = await remonsterItem.balanceOf(owner.address, token1);
    //         let tx2 = await monster.connect(owner).mintMonsterFromRegeneration(token1);

    //         const receipt2 = await tx2.wait();
    //         let token2;
    //         if (receipt2 && receipt2.events) {
    //             const events = receipt2.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token2 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(owner).ownerOf(token2)).to.equals(owner.address);
    //         await expect(monster.connect(owner).mintMonsterFromRegeneration(token1)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonsterFromRegeneration(token1)).not.to.be.reverted;
    //         await expect(monster.connect(owner).mintMonsterFromRegeneration(token1)).to.be.revertedWith("ERC1155: burn amount exceeds balance");
    //         let balance2 = await remonsterItem.balanceOf(owner.address, token1);
    //         expect(balance2).to.equals(balance1.toNumber() - number);
    //     });

    //     it('Should check event: mint EXTERNAL NFT', async function () {
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;
    //         const tokenUse = 0;

    //         const { monster, monsterMemory, owner, userAddress, tokenXXX, hashChip, treasuryAddress } = await loadFixture(deployERC721Fixture);
    //         await monster.connect(owner).initSetHashChipContract(hashChip.address);
    //         await monster.connect(owner).initSetValidator(owner.address);
    //         await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
    //         await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
    //         let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
    //         await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

    //         await hashChip.connect(owner).createNFT(owner.address, 0);
    //         await hashChip.connect(owner).createNFT(owner.address, 1);
    //         await hashChip.connect(owner).createNFT(owner.address, 2);

    //         let sig = await monster.connect(owner).encodeOAS(TypeMint.HASH_CHIP_NFT, cost, tokenUse, chainId, timestamp + 1000000);

    //         const signature = await signMessage(owner, sig.toString());

    //         let tx1 = await monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature);

    //         const receipt1 = await tx1.wait();
    //         let token1;
    //         if (receipt1 && receipt1.events) {
    //             const events = receipt1.events;
    //             const createEvent = events.find((event) => event.event === "createNFTMonster");
    //             if (createEvent && createEvent.args) {
    //                 token1 = createEvent.args?.tokenId.toString();
    //             }
    //         }
    //         expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
    //     });
    // })

    describe("Fusion Monster ", async function () {
        it('Should check function: fusionMonster', async function () {
            const { monster, monsterMemory, owner, userAddress, tokenXXX, remonsterItem, treasuryAddress } = await loadFixture(deployERC721Fixture);
            await monster.connect(owner).initSetRegenerationContract(remonsterItem.address);
            await monster.connect(owner).initSetValidator(owner.address);
            await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
            await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
            let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
            await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

            let number = 10;

            let itemRole = await remonsterItem.connect(owner).MANAGEMENT_ROLE();
            await remonsterItem.connect(owner).grantRole(itemRole, monster.address);

            let tx1 = await remonsterItem.connect(owner).mint(owner.address,1,1,number,"0x32");

            const receipt1 = await tx1.wait();
            let token1;
            if (receipt1 && receipt1.events) {
                const events = receipt1.events;
                const createEvent = events.find((event) => event.event === "mintMonsterItems");
                if (createEvent && createEvent.args) {
                    token1 = createEvent.args?.itemId.toString();
                }
            }

            let tx2 = await monster.connect(owner).mintMonsterFromRegeneration(token1);
            const receipt2 = await tx2.wait();
            let token2;
            if (receipt2 && receipt2.events) {
                const events = receipt2.events;
                const createEvent = events.find((event) => event.event === "createNFTMonster");
                if (createEvent && createEvent.args) {
                    token2 = createEvent.args?.tokenId.toString();
                }
            }

            let tx3 = await monster.connect(owner).mintMonsterFromRegeneration(token1);
            const receipt3 = await tx3.wait();
            let token3;
            if (receipt3 && receipt3.events) {
                const events = receipt3.events;
                const createEvent = events.find((event) => event.event === "createNFTMonster");
                if (createEvent && createEvent.args) {
                    token3 = createEvent.args?.tokenId.toString();
                }
            }
            
            await expect(monster.connect(owner).fusionMonsterNFT(owner.address, token2, token3, [token1], [1])).not.to.be.reverted;




        });

        // it('Should check event: mint EXTERNAL NFT', async function () {
        //     const blockNumber = await provider.getBlockNumber();
        //     const block = await provider.getBlock(blockNumber);
        //     const timestamp = block.timestamp;
        //     const network = await provider.getNetwork();
        //     const chainId = network.chainId;
        //     const tokenUse = 0;

        //     const { monster, monsterMemory, owner, userAddress, tokenXXX, hashChip, treasuryAddress } = await loadFixture(deployERC721Fixture);
        //     await monster.connect(owner).initSetHashChipContract(hashChip.address);
        //     await monster.connect(owner).initSetValidator(owner.address);
        //     await monster.connect(owner).initSetTreasuryAdress(treasuryAddress.address);
        //     await monster.connect(owner).initSetTokenBaseContract(tokenXXX.address);
        //     let xxxRole = await tokenXXX.connect(owner).MANAGEMENT_ROLE();
        //     await tokenXXX.connect(owner).grantRole(xxxRole, monster.address);

        //     await hashChip.connect(owner).createNFT(owner.address, 0);
        //     await hashChip.connect(owner).createNFT(owner.address, 1);
        //     await hashChip.connect(owner).createNFT(owner.address, 2);

        //     let sig = await monster.connect(owner).encodeOAS(TypeMint.HASH_CHIP_NFT, cost, tokenUse, chainId, timestamp + 1000000);

        //     const signature = await signMessage(owner, sig.toString());

        //     let tx1 = await monster.connect(owner).mintMonster(TypeMint.HASH_CHIP_NFT, tokenUse, false, cost, timestamp + 1000000, signature);

        //     const receipt1 = await tx1.wait();
        //     let token1;
        //     if (receipt1 && receipt1.events) {
        //         const events = receipt1.events;
        //         const createEvent = events.find((event) => event.event === "createNFTMonster");
        //         if (createEvent && createEvent.args) {
        //             token1 = createEvent.args?.tokenId.toString();
        //         }
        //     }
        //     expect(await monster.connect(owner).ownerOf(token1)).to.equals(owner.address);
        // });
    })
});
