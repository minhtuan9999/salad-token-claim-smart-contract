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

        const TrainingItem = await ethers.getContractFactory("EhanceItem");
        const trainingItem = await TrainingItem.connect(owner).deploy("https://example.com/");
        trainingItem.deployed();

        return { trainingItem, owner, userAddress };
    }

    describe("Test mint bath", function () {
        it('should check', async function () {
            const { trainingItem, owner } = await loadFixture(deployERC721Fixture);
            for (let i=0; i< 56; i++){
                await expect(trainingItem.connect(owner).mintMultipleItem(owner.address, [i], [10])).not.to.be.reverted;
            }
        });
    })
});
