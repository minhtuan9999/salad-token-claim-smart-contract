import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Remonster Item", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const RemonsterItem = await ethers.getContractFactory("RemonsterItem");
        const remonsterItem = await RemonsterItem.connect(owner).deploy("https://example.com/");
        remonsterItem.deployed();

        return { remonsterItem, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);

            expect(await remonsterItem.owner()).to.equal(owner.address);
        });
    })
    describe("Create item", function () {
        it('should check when the caller address has permission', async function () {
            const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);
            const collectionId = 1;
            const typeId = 2;
            await expect(remonsterItem.connect(owner).mint(owner.address,typeId, collectionId, 1, "")).not.to.be.reverted;
        });
        it('should check when the caller address has no permission', async function () {
            const { remonsterItem, userAddress } = await loadFixture(deployERC721Fixture);
            const collectionId = 1;
            const typeId = 2;
            await expect(remonsterItem.connect(userAddress).mint(userAddress.address,typeId, collectionId, 1, "")).to.be.reverted;
        });
        it('should check event create NFT', async function () {
            const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);
            const collectionId = 1;
            const typeId = 2;
            await expect(remonsterItem.connect(owner).mint(owner.address,typeId, collectionId, 1, ""))
                .to.emit(remonsterItem, "mintMonsterItems")
                .withArgs(owner.address, 0, 1,"");
        });
    })
    describe("should check balance item of address", function () {
        it('should check when the caller address has permission', async function () {
            const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);

            await remonsterItem.connect(owner).mint(owner.address,1, 0, 1, "0x32");
            expect(await remonsterItem.connect(owner).balanceOf(owner.address, 0)).to.equals(1);
        });
    })
    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);

            await remonsterItem.connect(owner).mint(owner.address,1, 0, 1, "0x32");
    
            await remonsterItem.burn(owner.address, 0, 1);
    
            const tokenIds = await remonsterItem.balanceOf(owner.address, 0);
            expect(tokenIds).to.equal(0);    
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { remonsterItem, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await remonsterItem.connect(owner).mint(owner.address,1, 0, 1, "0x32");
            await expect(remonsterItem.connect(userAddress).burn(owner.address, 0, 1)).to.be.reverted;

        });
    })
    // describe("Burn token id", function () {
    //     it("should check token uri of id", async function () {
    //         const { remonsterItem, owner } = await loadFixture(deployERC721Fixture);
    //         const tokenId = 0;
    //         await remonsterItem.connect(owner).mint(owner.address,1, tokenId, 1, "0x32");
    
    //         const uri = await remonsterItem.uri(tokenId);
    
    //         expect(uri).to.equal("https://example.com/" + tokenId.toString());    
    //     });
    // })
});
