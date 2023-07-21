import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("GeneralHash", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    const provider = ethers.provider;

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const GeneralHash = await ethers.getContractFactory("GeneralHash");
        const generalHash = await GeneralHash.connect(owner).deploy();
        generalHash.deployed();

        return { generalHash, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);

            expect(await generalHash.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await expect(generalHash.connect(owner).createNFT(owner.address, group)).to.be.revertedWith("General_Hash::_createNFT: Exceeding");
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(owner).createNFT(owner.address, 1)).not.to.be.reverted;
        });
        it('should check when the caller address has no permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        });
        it('should check event create NFT', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            let tokenId = await generalHash.connect(owner).totalSupply();
            await expect(generalHash.createNFT(owner.address, 1))
                .to.emit(generalHash, "createGeneralHash")
                .withArgs(owner.address, tokenId.toNumber(), 1);
        });
    })
    describe("Create Multiple NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).to.be.revertedWith("Genesis Hash::createMultipleNFT: Exceeding");
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).not.to.be.reverted;
        });

        it('should check when the caller address has no permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(userAddress).createMultipleGeneralHash(userAddress.address,number, group)).to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 3;
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);

            let tokenId = (await generalHash.connect(owner).totalSupply()).toNumber();

            await expect(generalHash.createMultipleGeneralHash(owner.address,number, group))
                .to.emit(generalHash, "createMultipleGeneral")
                .withArgs(owner.address, [tokenId,tokenId+1,tokenId+2], 1);
        });
    })

    describe("Create Multiple NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).to.be.revertedWith("Genesis Hash::createMultipleNFT: Exceeding");
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).not.to.be.reverted;
        });

        it('should check when the caller address has no permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await expect(generalHash.connect(userAddress).createMultipleGeneralHash(userAddress.address,number, group)).to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 3;
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);

            let tokenId = (await generalHash.connect(owner).totalSupply()).toNumber();

            await expect(generalHash.createMultipleGeneralHash(owner.address,number, group))
                .to.emit(generalHash, "createMultipleGeneral")
                .withArgs(owner.address, [tokenId,tokenId+1,tokenId+2], 1);
        });
    })

    // describe("random Species of general hash", function () {
    //     it('should check when the caller address has permission', async function () {
    //         const { generalHash, owner } = await loadFixture(deployERC721Fixture);
    //         const number = 1;
    //         const group = 1;
    //         const blockNumber = await provider.getBlockNumber();
    //         const block = await provider.getBlock(blockNumber);
    //         const timestamp = block.timestamp;
    //         const network = await provider.getNetwork();
    //         const chainId = network.chainId;

    //         await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).to.be.revertedWith("Genesis Hash::createMultipleNFT: Exceeding");
    //         await generalHash.connect(owner).initSetDetailGroup(group,100);
    //         await expect(generalHash.connect(owner).createMultipleGeneralHash(owner.address,number, group)).not.to.be.reverted;
            
    //     });
    // })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await generalHash.createNFT(owner.address, 1);

            const tokenIds = await generalHash.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await generalHash.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            
            let tx1 = await generalHash.createNFT(owner.address, 1);

            const receipt1 = await tx1.wait();
            let token1;
            if (receipt1 && receipt1.events) {
                const events = receipt1.events;
                const createEvent = events.find((event) => event.event === "createGeneralHash");
                if (createEvent && createEvent.args) {
                    token1 = createEvent.args?.tokenId.toString();
                }
            }
            let remainGroup1 = (await generalHash.connect(owner)._groupDetail(group)).remaining;
            await expect(generalHash.connect(owner).burn(token1)).not.to.be.reverted;
            
            const tokenIds = await generalHash.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(0);
    
            await expect(generalHash.ownerOf(0)).to.be.revertedWith("ERC721: invalid token ID");
            let remainGroup2 = (await generalHash.connect(owner)._groupDetail(group)).remaining;
            expect(remainGroup2.toNumber()).to.equal(remainGroup1.toNumber() + 1);
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { generalHash, owner, userAddress } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).initSetDetailGroup(group,100);
            await generalHash.connect(owner).createNFT(owner.address, 1);
            await expect(generalHash.connect(userAddress).burn(0)).to.be.reverted;
        });
    })
});
