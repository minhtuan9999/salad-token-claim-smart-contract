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
    describe("Create Box", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await expect(generalHash.connect(owner).createBox(userAddress.address,group)).not.to.be.reverted;
        });
        it('should check event create box', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await expect(generalHash.createBox(owner.address, group))
                .to.emit(generalHash, "createBoxs")
                .withArgs(owner.address, 1, group);
        });
    })
    describe("claimMaketingBox", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).claimMaketingBox(owner.address, group);
            await expect(generalHash.connect(userAddress).claimMaketingBox(owner.address, group)).to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;

            await expect(generalHash.claimMaketingBox(owner.address, group))
                .to.emit(generalHash, "createBoxs")
                .withArgs(owner.address, 80, group);
        });
    })

    describe("Open Box", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await generalHash.connect(owner).createBox(owner.address,group)
            await expect(generalHash.connect(owner).openGeneralBox(group)).not.to.be.reverted;
        });

        it('should check event create NFT', async function () {
            const { generalHash, owner } = await loadFixture(deployERC721Fixture);
            const group = 0;
            await generalHash.connect(owner).claimMaketingBox(owner.address, group);

            let tx1 = await generalHash.connect(owner).openGeneralBox(group);
        
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
            
            let tx2 = await generalHash.connect(owner).openGeneralBox(group);

            const receipt2 = await tx2.wait();
            let token2;
            if (receipt2 && receipt2.events) {
                const events = receipt2.events;
                const createEvent = events.find(
                    (event) => event.event === "openBoxs"
                );
                if (createEvent && createEvent.args) {
                    token2 = createEvent.args?._type.toString();
                }
            }

            let tx3 = await generalHash.connect(owner).openGeneralBox(group);

            const receipt3 = await tx3.wait();
            let token3;
            if (receipt3 && receipt3.events) {
                const events = receipt3.events;
                const createEvent = events.find(
                    (event) => event.event === "openBoxs"
                );
                if (createEvent && createEvent.args) {
                    token3 = createEvent.args?._type.toString();
                }
            }
        });
    })
    describe("burn", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;

            await generalHash.connect(owner).createBox(owner.address, group);
            await expect(generalHash.connect(owner).openGeneralBox(group)).not.to.be.reverted;
            await expect(generalHash.connect(owner).burn(0)).not.to.be.reverted;
        });
    })
    describe("Get infor", function () {
        it('should check when the caller address has permission', async function () {
            const { generalHash, userAddress, owner } = await loadFixture(deployERC721Fixture);
            const group = 1;
            await generalHash.connect(owner).createBox(owner.address, group);
            await expect(generalHash.connect(owner).openGeneralBox(group)).not.to.be.reverted;
            
            
        });
    })
});
