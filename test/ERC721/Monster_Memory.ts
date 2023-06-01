import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MonsterMemory", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const MonsterMemory = await ethers.getContractFactory("MonsterMemory");
        const monsterMemory = await MonsterMemory.connect(owner).deploy("MonsterMemory", "MonsterMemory");
        monsterMemory.deployed();

        return { monsterMemory, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            expect(await monsterMemory.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            await expect(monsterMemory.connect(owner).createNFT(owner.address, 1)).not.to.be.rejected;
        });
        it('should check when the caller address has no permission', async function () {
            const { monsterMemory, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monsterMemory.connect(userAddress).createNFT(userAddress.address, 1)).to.be.rejected;
        });
        it('should check event create NFT', async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            await expect(monsterMemory.createNFT(owner.address, 1))
                .to.emit(monsterMemory, "createMonsterMemory")
                .withArgs(owner.address, 0, 1);
        });
    })
    describe("Set token URI", function () {
        it("should set the correct token URI", async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            const baseURI = "https://example.com/";
            await monsterMemory.setBaseURI(baseURI);
            await monsterMemory.createNFT(owner.address, 1);
            expect(await monsterMemory.tokenURI(0)).to.equal(baseURI + "0");
        });
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            await monsterMemory.createNFT(owner.address, 1);

            const tokenIds = await monsterMemory.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await monsterMemory.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { monsterMemory, owner } = await loadFixture(deployERC721Fixture);

            await monsterMemory.createNFT(owner.address, 1);
    
            await monsterMemory.burn(0);
    
            const tokenIds = await monsterMemory.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(monsterMemory.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { monsterMemory, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monsterMemory.connect(owner).createNFT(owner.address, 1);
            await expect(monsterMemory.connect(userAddress).burn(0)).to.be.rejected;

        });
    })

});
