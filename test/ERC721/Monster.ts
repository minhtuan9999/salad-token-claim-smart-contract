import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Monster", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const Monster = await ethers.getContractFactory("Monster");
        const monster = await Monster.connect(owner).deploy("Monster", "Monster");
        monster.deployed();

        return { monster, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            expect(await monster.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(owner).createNFT(owner.address, 1)).not.to.be.rejected;
        });
        it('should check when the caller address has no permission', async function () {
            const { monster, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(userAddress).createNFT(userAddress.address, 1)).to.be.rejected;
        });
        it('should check event create NFT', async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await expect(monster.createNFT(owner.address, 1))
                .to.emit(monster, "createMonster")
                .withArgs(owner.address, 0, 1);
        });
    })

    describe("Create NFT Free", function () {
        it('should check when the caller address has permission', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(owner).createFreeNFT(owner.address)).not.to.be.rejected;
            await expect(monster.connect(userAddress).createFreeNFT(userAddress.address)).not.to.be.rejected;
        });
        it('should check when the address exist nft free', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(owner).createFreeNFT(owner.address)).not.to.be.rejected;
            await expect(monster.connect(userAddress).createFreeNFT(owner.address)).to.be.rejectedWith("Monster:: CreateFreeNFT: Exist NFT Free of address");
        });
        it('should check event create NFT Free', async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await expect(monster.createFreeNFT(owner.address))
                .to.emit(monster, "createMonsterFree")
                .withArgs(owner.address, 0);
        });
    })

    describe("Mint NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(owner).mint(owner.address)).not.to.be.rejected;
        });
        it('should check when the caller address has no permission', async function () {
            const { monster, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(monster.connect(userAddress).mint(userAddress.address)).to.be.rejected;
        });
    })
    describe("Set token URI", function () {
        it("should set the correct token URI", async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            const baseURI = "https://example.com/";
            await monster.setBaseURI(baseURI);
            await monster.createNFT(owner.address, 1);
            expect(await monster.tokenURI(0)).to.equal(baseURI + "0");
        });
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await monster.createNFT(owner.address, 1);

            const tokenIds = await monster.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await monster.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { monster, owner } = await loadFixture(deployERC721Fixture);

            await monster.createNFT(owner.address, 1);
    
            await monster.burn(0);
    
            const tokenIds = await monster.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(monster.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monster.connect(owner).createNFT(owner.address, 1);
            await expect(monster.connect(userAddress).burn(0)).to.be.rejected;

        });
    })

    describe("should check isFree ", function () {
        it('should check status isFree', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monster.connect(owner).mint(userAddress.address)
            await monster.connect(owner).createFreeNFT(userAddress.address)
            expect(( await monster.connect(owner).isFree(0)).toString()).to.equals("false")
            expect(( await monster.connect(owner).isFree(1)).toString()).to.equals("true")
            await expect(monster.connect(owner).isFree(2)).to.be.rejectedWith("Monster:: isFree: Monster not exists");
        });
    })
    describe("Life Span", function () {
        it('should check status life span', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await monster.connect(owner).mint(userAddress.address)
            expect(( await monster.connect(owner).getLifeSpan(0)).toString()).to.equals("true")
            await expect(monster.connect(owner).getLifeSpan(2)).to.be.rejectedWith("Monster:: getLifeSpan: Monster not exists");
        });
        it('should check setLifeSpan when has permission', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);
            const status = false;

            await monster.connect(owner).mint(userAddress.address);
            await monster.connect(owner).setStatusLifeSpan(0, status)
            expect(await monster.connect(owner).getLifeSpan(0)).to.equals(status);
            await expect(monster.connect(owner).getLifeSpan(1)).to.be.rejectedWith("Monster:: getLifeSpan: Monster not exists");

        });
        it('should check setLifeSpan when has not permission', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);
            const status = false;

            await monster.connect(owner).mint(userAddress.address);
            await expect(monster.connect(userAddress).setStatusLifeSpan(0, status)).to.be.rejected;
        });
        it('should check event setLifeSpan', async function () {
            const { monster, owner, userAddress } = await loadFixture(deployERC721Fixture);
            const status = false;

            await monster.connect(owner).mint(userAddress.address);
            await expect(monster.setStatusLifeSpan(0, status))
                .to.emit(monster, "statusLifeSpan")
                .withArgs(0, status);
        });
    })
});
