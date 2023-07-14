import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("GenesisHash", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    const provider = ethers.provider;

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const GenesisHash = await ethers.getContractFactory("GenesisHash");
        const genesisHash = await GenesisHash.connect(owner).deploy();
        genesisHash.deployed();

        return { genesisHash, owner, userAddress };
    }

    describe("Deployment", function () {
        it('should deploy and set the owner correctly', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);

            expect(await genesisHash.owner()).to.equal(owner.address);
        });
    })
    describe("Create NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await expect(genesisHash.connect(owner).createNFT(owner.address, group)).to.be.revertedWith("Genesis Hash::_createNFT: Exceeding");
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await expect(genesisHash.connect(owner).createNFT(owner.address, 1)).not.to.be.reverted;
        });
        it('should check when the caller address has no permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await expect(genesisHash.connect(userAddress).createNFT(userAddress.address, 1)).to.be.reverted;
        });
        it('should check event create NFT', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            let tokenId = await genesisHash.connect(owner).totalSupply();
            await expect(genesisHash.createNFT(owner.address, 1))
                .to.emit(genesisHash, "createGenesisHash")
                .withArgs(owner.address, tokenId.toNumber(), 1);
        });
    })
    describe("Create Multiple NFT", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await expect(genesisHash.connect(owner).createMultipleNFT(owner.address,number, group)).to.be.revertedWith("Genesis Hash::createMultipleNFT: Exceeding");
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await expect(genesisHash.connect(owner).createMultipleNFT(owner.address,number, group)).not.to.be.reverted;
        });

        it('should check when the caller address has no permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const number = 1;
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await expect(genesisHash.connect(userAddress).createMultipleNFT(userAddress.address,number, group)).to.be.reverted;
        });

        it('should check event create Multiple NFT', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const number = 3;
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);

            let tokenId = (await genesisHash.connect(owner).totalSupply()).toNumber();

            await expect(genesisHash.createMultipleNFT(owner.address,number, group))
                .to.emit(genesisHash, "createMultipleGenesis")
                .withArgs(owner.address, [tokenId,tokenId+1,tokenId+2], 1);
        });
    })

    describe("Get list tokens of address", function () {
        it("should mint a new token and update the token lists", async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await genesisHash.createNFT(owner.address, 1);

            const tokenIds = await genesisHash.getListTokensOfAddress(owner.address);
            expect(tokenIds.length).to.equal(1);
            expect(tokenIds[0]).to.equal(0);

            const ownerOfToken = await genesisHash.ownerOf(0);
            expect(ownerOfToken).to.equal(owner.address);
        });
    })

    describe("Burn token id", function () {
        it("should burn a token with caller address has permission ", async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            
            let tx1 = await genesisHash.createNFT(owner.address, 1);

            const receipt1 = await tx1.wait();
            let token1;
            if (receipt1 && receipt1.events) {
                const events = receipt1.events;
                const createEvent = events.find((event) => event.event === "createGenesisHash");
                if (createEvent && createEvent.args) {
                    token1 = createEvent.args?.tokenId.toString();
                }
            }     
            const tokenIds = await genesisHash.getListTokensOfAddress(owner.address);
            await expect(genesisHash.connect(owner).burn(token1)).not.to.be.reverted;
            expect((tokenIds.length - 1).toString()).to.equal(tokenIds.toString());
        });
        it("should burn a token with caller address has no permission ", async function () {
            const { genesisHash, owner, userAddress } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).initSetDetailGroup(group,100);
            await genesisHash.connect(owner).createNFT(owner.address, 1);
            await expect(genesisHash.connect(userAddress).burn(0)).to.be.reverted;
        });
    })
});
