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
    describe("Create Box", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await expect(genesisHash.connect(owner).createBox(userAddress.address,group)).not.to.be.reverted;
        });
        it('should check event create box', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await expect(genesisHash.createBox(owner.address, group))
                .to.emit(genesisHash, "createBoxs")
                .withArgs(owner.address, 1, group);
        });
    })
    describe("claimMaketingBox", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await genesisHash.connect(owner).claimMaketingBox(owner.address, group);
            await expect(genesisHash.connect(userAddress).claimMaketingBox(owner.address, group)).to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;

            await expect(genesisHash.claimMaketingBox(owner.address, group))
                .to.emit(genesisHash, "createBoxs")
                .withArgs(owner.address, 120, group);
        });
    })

    describe("claim Maketing Type", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 2;
            await genesisHash.connect(owner).claimMaketingWithType(owner.address, group);
            await expect(genesisHash.connect(userAddress).claimMaketingWithType(owner.address, group)).to.be.reverted;
            console.log("===================================")
            console.log(await genesisHash.getDetailGroup(group));
        });
    })

    describe("Open Box", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await genesisHash.connect(owner).createBox(owner.address,group)
            await expect(genesisHash.connect(owner).openGenesisBox(group)).not.to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { genesisHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await genesisHash.connect(owner).claimMaketingBox(owner.address, group);

            let tx1 = await genesisHash.connect(owner).openGenesisBox(group);
        
            const receipt1 = await tx1.wait();
            let token1;
            if (receipt1 && receipt1.events) {
                const events = receipt1.events;
                const createEvent = events.find(
                    (event) => event.event === "openBoxs"
                );
                if (createEvent && createEvent.args) {
                    token1 = createEvent.args?._type.toString();
                }
            }
            console.log(token1);
        });
    })
    describe("burn", function () {
        it('should check when the caller address has permission', async function () {
            const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;

            await genesisHash.connect(owner).createBox(owner.address, group);
            await expect(genesisHash.connect(owner).openGenesisBox(group)).not.to.be.reverted;
            await expect(genesisHash.connect(owner).burn(0)).not.to.be.reverted;
        });
    })
    // describe("Get infor", function () {
    //     it('should check when the caller address has permission', async function () {
    //         const { genesisHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
    //         const group = 1;

    //         await genesisHash.connect(owner).createBox(owner.address, group);
    //         console.log(await genesisHash.getDetailAddress(owner.address));
    //         console.log(await genesisHash.getTypeOfListToken([0]));
    //         console.log(await genesisHash.getDetailGroup(group));
    //         await expect(genesisHash.connect(owner).openGenesisBox(group)).not.to.be.reverted;
    //         console.log(await genesisHash.getDetailAddress(owner.address));
            
            
    //     });
    // })
});
