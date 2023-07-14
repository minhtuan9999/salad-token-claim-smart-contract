import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("HashChipNFT", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const HashChipNFT = await ethers.getContractFactory("HashChipNFT");
        const hashChip = await HashChipNFT.connect(owner).deploy();
        hashChip.deployed();

        return { hashChip, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { hashChip, owner } = await loadFixture(deployERC721Fixture);

            expect(await hashChip.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { hashChip, owner } = await loadFixture(deployERC721Fixture);

            await expect(hashChip.connect(owner).createNFT(owner.address, 1)).not.to.be.reverted;
        });
        it('should check when the caller address has no permission', async function () {
            const { hashChip, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(hashChip.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        });
        it('should check event create NFT', async function () {
            const { hashChip, owner } = await loadFixture(deployERC721Fixture);
            const tokenId = 1;
            await expect(hashChip.createNFT(owner.address, tokenId))
                .to.emit(hashChip, "createHashChipNFT")
                .withArgs(owner.address, tokenId);
        });
        it('should check status isFree of Coach', async function () {
            const { hashChip, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(hashChip.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        })
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { hashChip, owner } = await loadFixture(deployERC721Fixture);

            await hashChip.createNFT(owner.address, 1);

            const tokenIds = await hashChip.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await hashChip.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { hashChip, owner } = await loadFixture(deployERC721Fixture);
            let tokenId = 1;
            await hashChip.createNFT(owner.address, tokenId);
    
            await hashChip.burn(tokenId);
    
            const tokenIds = await hashChip.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(hashChip.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { hashChip, owner, userAddress } = await loadFixture(deployERC721Fixture);
            let tokenId = 1;

            await hashChip.connect(owner).createNFT(owner.address, tokenId);
            await expect(hashChip.connect(userAddress).burn(tokenId)).to.be.reverted;

        });
    })

});
