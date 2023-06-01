import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Monster Managerment", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const Accessories = await ethers.getContractFactory("Accessories");
        const accessories = await Accessories.connect(owner).deploy("Accessories", "Accessories");
        accessories.deployed();

        const Coach = await ethers.getContractFactory("Coach");
        const coach = await Coach.connect(owner).deploy("Coach", "Coach");
        coach.deployed();

        const GeneralHash = await ethers.getContractFactory("GeneralHash");
        const generalHash = await GeneralHash.connect(owner).deploy("GeneralHash", "GeneralHash");
        generalHash.deployed();

        const GenesisHash = await ethers.getContractFactory("GenesisHash");
        const genesisHash = await GenesisHash.connect(owner).deploy("GenesisHash", "GenesisHash");
        genesisHash.deployed();

        const MonsterCrystal = await ethers.getContractFactory("MonsterCrystal");
        const monsterCrystal = await MonsterCrystal.connect(owner).deploy("MonsterCrystal", "MonsterCrystal");
        monsterCrystal.deployed();

        const MonsterMemory = await ethers.getContractFactory("MonsterMemory");
        const monsterMemory = await MonsterMemory.connect(owner).deploy("MonsterMemory", "MonsterMemory");
        monsterMemory.deployed();

        const Monster = await ethers.getContractFactory("Monster");
        const monster = await Monster.connect(owner).deploy("Monster", "Monster");
        monster.deployed();

        const Skin = await ethers.getContractFactory("Skin");
        const skin = await Skin.connect(owner).deploy("Skin", "Skin");
        skin.deployed();

        const RemonsterItem = await ethers.getContractFactory("RemonsterItem");
        const remonsterItem = await RemonsterItem.connect(owner).deploy("https://example.com/");
        remonsterItem.deployed();

        const MonsterManagerment = await ethers.getContractFactory("MonsterManagerment");
        const monsterManagerment = await MonsterManagerment.connect(owner).deploy(monster.address, monsterMemory.address, coach.address, monsterCrystal.address, genesisHash.address, generalHash.address, accessories.address, remonsterItem.address);
        monsterManagerment.deployed();

        return { monsterManagerment, accessories, coach, monster, monsterCrystal, monsterMemory, generalHash, genesisHash, skin, owner, userAddress, remonsterItem };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { monsterManagerment, owner } = await loadFixture(deployERC721Fixture);

            expect(await monsterManagerment.owner()).to.equal(owner.address);
        });
    })
//     describe("fusionMonsterNFT", function () {
//         describe("two monster at the not end of life", function () {
//             describe("not using fusion item", function () {
//                 it('should check fusion when has permission', async function () {
//                     const { monsterManagerment, monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     let fusionItem = [0];
//                     let numberList = [0];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(0);

//                 });

//                 it('should check fusion when has not permission', async function () {
//                     const { monsterManagerment, monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }

//                     let fusionItem = [0];
//                     let numberList = [0];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).to.be.rejected;
//                 });
//                 it('should check event', async function () {
//                     const { monsterManagerment, monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     let fusionItem = [0];
//                     let numberList = [0];
//                     const newToken = parseInt(token2, 10) + 1;

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList))
//                         .to.emit(monsterManagerment, "fusionNFTMonsterMemory")
//                         .withArgs(owner.address, newToken, token1, token2);
//                 });
//             })
//             describe("using fusion item", function () {
//                 it('eligible', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }

//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let balanceItem = (await remonsterItem.connect(owner).balanceOf(owner.address, item)).toNumber();
//                     let fusionItem = [item];
//                     let numberList = [0];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(0);

//                     expect(await remonsterItem.connect(owner).balanceOf(owner.address, item)).to.equals(balanceItem - numberList[0]);
//                 });
//                 it('invalid input', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }

//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let fusionItem = [item];
//                     let numberList = [0,1];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).to.be.rejectedWith("MonsterManagerment: fusionMonsterNFT: Invalid input");
//                 });
//             })

//         })
//         describe("two monster at the one end of life", function () {
//             describe("not using fusion item", function () {
//                 it('should check fusion when has permission', async function () {
//                     const { monsterManagerment, monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);
//                     // await monster.connect(owner).setStatusLifeSpan(token2, false);

//                     let fusionItem = [0];
//                     let numberList = [0];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(1);

//                 });
//             })
//             describe("using fusion item", function () {
//                 it('eligible', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }

//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let balanceItem = (await remonsterItem.connect(owner).balanceOf(owner.address, item)).toNumber();
//                     let fusionItem = [item];
//                     let numberList = [0];
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(1);

//                     expect(await remonsterItem.connect(owner).balanceOf(owner.address, item)).to.equals(balanceItem - numberList[0]);
//                 });
//                 it('invalid input', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
// 1
//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let fusionItem = [item];
//                     let numberList = [0,1];
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).to.be.rejectedWith("MonsterManagerment: fusionMonsterNFT: Invalid input");
//                 });
//             })

//         })
//         describe("two monster at the two end of life", function () {
//             describe("not using fusion item", function () {
//                 it('should check fusion when has permission', async function () {
//                     const { monsterManagerment, monster, monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);
//                     await monster.connect(owner).setStatusLifeSpan(token2, false);

//                     let fusionItem = [0];
//                     let numberList = [0];

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(2);

//                 });
//             })
//             describe("using fusion item", function () {
//                 it('eligible', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }

//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let balanceItem = (await remonsterItem.connect(owner).balanceOf(owner.address, item)).toNumber();
//                     let fusionItem = [item];
//                     let numberList = [0];
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);
//                     await monster.connect(owner).setStatusLifeSpan(token2, false);

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;

//                     await expect(monster.ownerOf(token1)).to.be.revertedWith("ERC721: invalid token ID");
//                     await expect(monster.ownerOf(token2)).to.be.revertedWith("ERC721: invalid token ID");

//                     const tokenMonster = await monster.getListTokensOfAddress(owner.address);
//                     expect(tokenMonster.length).to.equal(1);

//                     const tokenMemory = await monsterMemory.getListTokensOfAddress(owner.address);
//                     expect(tokenMemory.length).to.equal(2);

//                     expect(await remonsterItem.connect(owner).balanceOf(owner.address, item)).to.equals(balanceItem - numberList[0]);
//                 });
//                 it('invalid input', async function () {
//                     const { monsterManagerment, monster, monsterMemory, remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

//                     monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);
//                     monsterMemory.connect(owner).grantRole(monsterMemory.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

//                     let sendTx1 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let sendTx2 = await monster.connect(owner).createNFT(owner.address, 1);
//                     let token1;
//                     let token2;
//                     let item;
//                     const receipt1 = await sendTx1.wait();
//                     if (receipt1 && receipt1.events) {
//                         const events = receipt1.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token1 = createEvent.args?._tokenId.toString();
//                         }
//                     }
//                     const receipt2 = await sendTx2.wait();
//                     if (receipt2 && receipt2.events) {
//                         const events = receipt2.events;
//                         const createEvent = events.find((event) => event.event === "createMonster");
//                         if (createEvent && createEvent.args) {
//                             token2 = createEvent.args?._tokenId.toString();
//                         }
//                     }
// 1
//                     let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, 2, "0x32");
//                     const receipt3 = await sendTx3.wait();
//                     if (receipt3 && receipt3.events) {
//                         const events = receipt3.events;
//                         const createEvent = events.find((event) => event.event === "mintMonsterItems");
//                         if (createEvent && createEvent.args) {
//                             item = createEvent.args?._itemId.toString();
//                         }
//                     }
//                     let fusionItem = [item];
//                     let numberList = [0,1];
//                     await monster.connect(owner).setStatusLifeSpan(token1, false);
//                     await monster.connect(owner).setStatusLifeSpan(token2, false);

//                     await expect(monsterManagerment.connect(owner).fusionMonsterNFT(owner.address, token1, token2, fusionItem, numberList)).to.be.rejectedWith("MonsterManagerment: fusionMonsterNFT: Invalid input");
//                 });
//             })

//         })
//     })

    // describe("fusionGenesisHash", function() {
    //     describe(" not fusion item", function() {
    //         it("should check eligible", async function() {
    //             const { monsterManagerment, owner, genesisHash, monster } = await loadFixture(deployERC721Fixture);   
    //             monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

    //             let sendTx1 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let sendTx2 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let token1, token2, newToken;

    //             const receipt1 = await sendTx1.wait();
    //             if (receipt1 && receipt1.events) {
    //                 const events = receipt1.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token1 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             const receipt2 = await sendTx2.wait();
    //             if (receipt2 && receipt2.events) {
    //                 const events = receipt2.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token2 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             let fusionItem = [0];
    //             let numberList = [0];

    //             await expect(monsterManagerment.connect(owner).fusionGenesisHash(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;
    //             expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);
    //         })

    //         it("should check event", async function(){
    //             const { monsterManagerment, owner, genesisHash, monster } = await loadFixture(deployERC721Fixture);   
    //             monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

    //             let sendTx1 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let sendTx2 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let token1, token2, newToken;

    //             const receipt1 = await sendTx1.wait();
    //             if (receipt1 && receipt1.events) {
    //                 const events = receipt1.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token1 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             const receipt2 = await sendTx2.wait();
    //             if (receipt2 && receipt2.events) {
    //                 const events = receipt2.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token2 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             let fusionItem = [0];
    //             let numberList = [0];

    //             await expect(monsterManagerment.connect(owner).fusionGenesisHash(owner.address, token1, token2, fusionItem, numberList))
    //             .to.emit(monsterManagerment, "fusionGenesisHashNFT")
    //             .withArgs(owner.address, token1, token2, 0);
    //             expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);
    //         })
    //     })
    //     describe("using fusion item", function() {
    //         it("should check eligible", async function() {
    //             const { monsterManagerment, owner, genesisHash, monster, remonsterItem } = await loadFixture(deployERC721Fixture);   
    //             monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

    //             let sendTx1 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let sendTx2 = await genesisHash.connect(owner).createNFT(owner.address,0);
    //             let token1, token2, newToken, item;

    //             const receipt1 = await sendTx1.wait();
    //             if (receipt1 && receipt1.events) {
    //                 const events = receipt1.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token1 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             const receipt2 = await sendTx2.wait();
    //             if (receipt2 && receipt2.events) {
    //                 const events = receipt2.events;
    //                 const createEvent = events.find((event) => event.event === "createGenesisHash");
    //                 if (createEvent && createEvent.args) {
    //                     token2 = createEvent.args?._tokenId.toString();
    //                 }
    //             }
    //             let numberItem = 5;
    //             let itemUse = 1;

    //             let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, numberItem, "0x32");
    //             const receipt3 = await sendTx3.wait();
    //             if(receipt3 && receipt3.events) {
    //                 const events = receipt3.events;
    //                 const mintEvent = events.find((event) => event.event === "mintMonsterItems");
    //                 if(mintEvent && mintEvent.args) {
    //                     item = mintEvent.args._itemId.toString();
    //                 }
    //             }

    //             let fusionItem = [item];
    //             let numberList = [1];
                
    //             await expect(monsterManagerment.connect(owner).fusionGenesisHash(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;
    //             expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);

    //             expect(await remonsterItem.connect(owner).balanceOf(owner.address, item)).to.equals(numberItem-itemUse);

    //         })
    //     })
    // })
    describe("fusionGeneralHash", function() {
        describe(" not fusion item", function() {
            it("should check eligible", async function() {
                const { monsterManagerment, owner, generalHash, monster } = await loadFixture(deployERC721Fixture);   
                monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

                let sendTx1 = await generalHash.connect(owner).createNFT(owner.address,0);
                let sendTx2 = await generalHash.connect(owner).createNFT(owner.address,0);
                let token1, token2, newToken;

                const receipt1 = await sendTx1.wait();
                if (receipt1 && receipt1.events) {
                    const events = receipt1.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token1 = createEvent.args?._tokenId.toString();
                    }
                }
                const receipt2 = await sendTx2.wait();
                if (receipt2 && receipt2.events) {
                    const events = receipt2.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token2 = createEvent.args?._tokenId.toString();
                    }
                }
                let fusionItem = [0];
                let numberList = [0];
                // fusion first times
                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;
                expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);

                // fusion 2nd
                await monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList)
                expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(2);
                
                // fusion 3 times and burn general hash
                await monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList)
                expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(3);

                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList)).to.be.rejected;
            })

            it("should check event", async function(){
                const { monsterManagerment, owner, generalHash, monster } = await loadFixture(deployERC721Fixture);   
                monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

                let sendTx1 = await generalHash.connect(owner).createNFT(owner.address,0);
                let sendTx2 = await generalHash.connect(owner).createNFT(owner.address,0);
                let token1, token2, newToken;

                const receipt1 = await sendTx1.wait();
                if (receipt1 && receipt1.events) {
                    const events = receipt1.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token1 = createEvent.args?._tokenId.toString();
                    }
                }
                const receipt2 = await sendTx2.wait();
                if (receipt2 && receipt2.events) {
                    const events = receipt2.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token2 = createEvent.args?._tokenId.toString();
                    }
                }
                let fusionItem = [0];
                let numberList = [0];
                
                // fusion first times
                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList))
                .to.emit(monsterManagerment, "fusionGeneralHashNFT")
                .withArgs(owner.address, token1, token2, 0);

                // fusion 2nd
                expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);
                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList))
                .to.emit(monsterManagerment, "fusionGeneralHashNFT")
                .withArgs(owner.address, token1, token2, 1);

                // fusion 3 times
                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList))
                .to.emit(monsterManagerment, "fusionGeneralHashNFT")
                .withArgs(owner.address, token1, token2, 2);
            })
        })
        describe("using fusion item", function() {
            it("should check eligible", async function() {
                const { monsterManagerment, owner, generalHash, monster, remonsterItem } = await loadFixture(deployERC721Fixture);   
                monster.connect(owner).grantRole(monster.connect(owner).MANAGERMENT_ROLE(), monsterManagerment.address);

                let sendTx1 = await generalHash.connect(owner).createNFT(owner.address,0);
                let sendTx2 = await generalHash.connect(owner).createNFT(owner.address,0);
                let token1, token2, newToken, item;

                const receipt1 = await sendTx1.wait();
                if (receipt1 && receipt1.events) {
                    const events = receipt1.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token1 = createEvent.args?._tokenId.toString();
                    }
                }
                const receipt2 = await sendTx2.wait();
                if (receipt2 && receipt2.events) {
                    const events = receipt2.events;
                    const createEvent = events.find((event) => event.event === "createGeneralHash");
                    if (createEvent && createEvent.args) {
                        token2 = createEvent.args?._tokenId.toString();
                    }
                }
                let numberItem = 5;
                let itemUse = 1;

                let sendTx3 = await remonsterItem.connect(owner).mint(owner.address, 1, 1, numberItem, "0x32");
                const receipt3 = await sendTx3.wait();
                if(receipt3 && receipt3.events) {
                    const events = receipt3.events;
                    const mintEvent = events.find((event) => event.event === "mintMonsterItems");
                    if(mintEvent && mintEvent.args) {
                        item = mintEvent.args._itemId.toString();
                    }
                }

                let fusionItem = [item];
                let numberList = [1];
                
                await expect(monsterManagerment.connect(owner).fusionGeneralHash(owner.address, token1, token2, fusionItem, numberList)).not.to.be.rejected;
                expect(await monster.connect(owner).balanceOf(owner.address)).to.equals(1);

                expect(await remonsterItem.connect(owner).balanceOf(owner.address, item)).to.equals(numberItem-itemUse);

            })
        })
    })
});
