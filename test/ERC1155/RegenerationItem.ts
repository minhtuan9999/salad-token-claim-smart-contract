import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Training Item", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const TrainingItem = await ethers.getContractFactory("RegenerationItem");
        const trainingItem = await TrainingItem.connect(owner).deploy("https://example.com/");
        trainingItem.deployed();

        return { trainingItem, owner, userAddress };
    }

    describe("Test mint bath", function () {
        it('should check', async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);
            const id = [2,3,4,5];
            const number = [2,2,2,2];
            await expect(trainingItem.connect(owner).mintMultipleItem(owner.address, id, number)).not.to.be.reverted;
        });
        it("Should return the correct base metadata", async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);
            expect(await trainingItem.baseMetadata()).to.equal("https://example.com/");
        });
    
        it("Should mint a regeneration item", async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);

            await trainingItem.addTrainingItem("Item1", 1, 100); // Add an item
            await trainingItem.mint(owner.address, 0, 10, "0x"); // Mint 10 units of item with ID 0
            expect(await trainingItem.balanceOf(owner.address, 0)).to.equal(10);
        });
    
        it("Should mint multiple regeneration items", async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);

            await trainingItem.addTrainingItem("Item2", 1, 100); // Add an item
            await trainingItem.addTrainingItem("Item3", 1, 100); // Add another item
            await trainingItem.mintMultipleItem(owner.address, [0, 2], [5, 7]); // Mint 5 units of item 1 and 7 units of item 2
            expect(await trainingItem.balanceOf(owner.address, 0)).to.equal(5);
            expect(await trainingItem.balanceOf(owner.address, 2)).to.equal(7);
        });
    
        it("Should burn a regeneration item", async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);

            await trainingItem.addTrainingItem("Item4", 1, 100); // Add an item
            await trainingItem.mint(owner.address, 3, 10, "0x"); // Mint 10 units of item with ID 3
            await trainingItem.burn(owner.address, 3, 5); // Burn 5 units of item with ID 3
            expect(await trainingItem.balanceOf(owner.address, 3)).to.equal(5);
        });
    })
});
