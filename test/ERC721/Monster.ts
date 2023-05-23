import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ReMonsterMarketplace", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployMarketplaceFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount1, ownerNFT, ownerOAS] = await ethers.getSigners();

        const totalSupply = "100000000000000000000000000000";
        const feeSeller = "10000000000000000000"; // 10% * 10^18
        const addressReceiceFee = owner.address;

        const Test20 = await ethers.getContractFactory("Test20");
        const test20 = await Test20.connect(ownerOAS).deploy(totalSupply);
        test20.deployed();

        const Marketplace = await ethers.getContractFactory("ReMonsterMarketplace");
        const marketplace = await Marketplace.deploy(feeSeller, addressReceiceFee, test20.address);
        marketplace.deployed();

        const Test721 = await ethers.getContractFactory("Test721");
        const test721 = await Test721.connect(ownerNFT).deploy();
        test721.deployed();

        const Test1155 = await ethers.getContractFactory("Test1155");
        const test1155 = await Test1155.connect(ownerNFT).deploy();
        test1155.deployed();

        return { marketplace, test721, test1155, test20, feeSeller, addressReceiceFee, owner, otherAccount1, ownerNFT, ownerOAS };
    }

    describe("Deployment", function () {
        it("Should set the right feeSeller", async function () {
            const { marketplace, feeSeller } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.feeSeller()).to.equal(feeSeller);
        });

        it("Should set the right addressReceiceFee", async function () {
            const { marketplace, addressReceiceFee } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.addressReceiveFee()).to.equal(addressReceiceFee);
        });

        it("Should set the right addressTokenBase", async function () {
            const { marketplace, test20 } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.tokenBase()).to.equal(test20.address);
        });

        it("Should set the right owner", async function () {
            const { marketplace, owner } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.owner()).to.equal(owner.address);
        });
    });

});
