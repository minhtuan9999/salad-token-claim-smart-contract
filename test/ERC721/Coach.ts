import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Coach", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const Coach = await ethers.getContractFactory("Coach");
        const coach = await Coach.connect(owner).deploy();
        coach.deployed();

        return { coach, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);

            expect(await coach.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);

            await expect(coach.connect(owner).createNFT(owner.address, 1)).not.to.be.reverted;
        });
        it('should check when the caller address has no permission', async function () {
            const { coach, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(coach.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        });

        it('should check status isFree of Coach', async function () {
            const { coach, userAddress } = await loadFixture(deployERC721Fixture);

            await expect(coach.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        });
        it('should check event create NFT', async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);
            const type = 1;
            let totalSupply = await coach.totalSupply();

            await expect(coach.createNFT(owner.address, type))
                .to.emit(coach, "createCoach")
                .withArgs(owner.address, totalSupply, type);
        });
    })
    describe("Set token URI", function () {
        it("should set the correct token URI", async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);

            const baseURI = "https://example.com/";
            await coach.setBaseURI(baseURI);
            await coach.createNFT(owner.address, 1);
            expect(await coach.tokenURI(0)).to.equal(baseURI + "0");
        });
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);

            await coach.createNFT(owner.address, 1);

            const tokenIds = await coach.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await coach.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { coach, owner } = await loadFixture(deployERC721Fixture);

            await coach.createNFT(owner.address, 1);
    
            await coach.burn(0);
    
            const tokenIds = await coach.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(coach.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { coach, owner, userAddress } = await loadFixture(deployERC721Fixture);

            await coach.connect(owner).createNFT(owner.address, 1);
            await expect(coach.connect(userAddress).burn(0)).to.be.reverted;

        });
    })
    // describe("create Coach From Monster", function () {
    //     it('should check status isFree of Coach', async function () {
    //         const { coach, owner, userAddress } = await loadFixture(deployERC721Fixture);

    //         await coach.connect(owner).createNFT(owner.address, 1)

    //         expect(( await coach.connect(owner).isFree(0)).toString()).to.equals("true")
    //         await expect(coach.connect(owner).isFree(1)).to.be.rejectedWith("Coach:: isFree: Monster not exists");
    //     });
    // })
});
