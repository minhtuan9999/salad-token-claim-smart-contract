import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("MonsterCrystal", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const MonsterCrystal = await ethers.getContractFactory("MonsterCrystal");
        const monsterCrystal = await MonsterCrystal.connect(owner).deploy("MonsterCrystal", "MonsterCrystal");
        monsterCrystal.deployed();

        return { monsterCrystal, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            expect(await monsterCrystal.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            await expect(monsterCrystal.connect(owner).createNFT(owner.address, 1)).not.to.be.rejected;
        });
        it('should check when the caller address has no permission', async function () {
            const { monsterCrystal, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monsterCrystal.connect(userAddress).createNFT(userAddress.address, 1)).to.be.rejected;
        });
        it('should check event create NFT', async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            await expect(monsterCrystal.createNFT(owner.address, 1))
                .to.emit(monsterCrystal, "createMonsterCrystal")
                .withArgs(owner.address, 0, 1);
        });
    })
    describe("Mint NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            await expect(monsterCrystal.connect(owner).mint(owner.address, true)).not.to.be.rejected;
        });
        it('should check when the caller address has no permission', async function () {
            const { monsterCrystal, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monsterCrystal.connect(userAddress).mint(userAddress.address, true)).to.be.rejected;
        });
    })
    describe("Set token URI", function () {
        it("should set the correct token URI", async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            const baseURI = "https://example.com/";
            await monsterCrystal.setBaseURI(baseURI);
            await monsterCrystal.createNFT(owner.address, 1);
            expect(await monsterCrystal.tokenURI(0)).to.equal(baseURI + "0");
        });
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            await monsterCrystal.createNFT(owner.address, 1);

            const tokenIds = await monsterCrystal.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await monsterCrystal.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { monsterCrystal, owner } = await loadFixture(deployERC721Fixture);

            await monsterCrystal.createNFT(owner.address, 1);
    
            await monsterCrystal.burn(0);
    
            const tokenIds = await monsterCrystal.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(monsterCrystal.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { monsterCrystal, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monsterCrystal.connect(owner).createNFT(owner.address, 1);
            await expect(monsterCrystal.connect(userAddress).burn(0)).to.be.rejected;

        });
    })
    describe("should check isFree", function () {
        it('should check status isFree', async function () {
            const { monsterCrystal, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monsterCrystal.connect(owner).mint(userAddress.address, true)
            expect(( await monsterCrystal.connect(owner).isFree(0)).toString()).to.equals("true")
            await expect(monsterCrystal.connect(owner).isFree(1)).to.be.rejectedWith("Monster Crystal:: isFree: Monster not exists");
        });
    })

});
