import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Shop", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    const provider = ethers.provider;
    const feeSeller = (10 * 10**18).toString();
    const generalPrice = (10**18).toString();
    const genesisPrice = (10**18).toString();
    const farmPrice = (10**18).toString();
    const bitPrice = (10**18).toString();

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const GeneralHash = await ethers.getContractFactory("GeneralHash");
        const generalHash = await GeneralHash.connect(owner).deploy();
        generalHash.deployed();

        const GenesisHash = await ethers.getContractFactory("GenesisHash");
        const genesisHash = await GenesisHash.connect(owner).deploy();
        genesisHash.deployed();
        
        const Farm = await ethers.getContractFactory("ReMonsterFarm");
        const farm = await Farm.connect(owner).deploy("Farm", "FARM", 5000);
        farm.deployed();

        const TrainingItem = await ethers.getContractFactory("TrainingItem");
        const trainingItem = await TrainingItem.connect(owner).deploy("");
        trainingItem.deployed();

        const Shop = await ethers.getContractFactory("ReMonsterShop");
        const shop = await Shop.connect(owner).deploy();
        shop.deployed();

        shop.initContract(generalHash.address, genesisHash.address, farm.address, trainingItem.address);

        return { shop, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { shop, owner } = await loadFixture(deployERC721Fixture);

            expect(await shop.owner()).to.equal(owner.address);
        });
    })
    describe("Get list sale", function () {
        it('should check when the caller address has permission', async function () {
            const { shop, owner } = await loadFixture(deployERC721Fixture);
            await expect(shop.connect(owner).getListSale()).not.to.be.reverted;
        });
       
    })
});
