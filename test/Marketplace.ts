import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ReMonsterMarketplace", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployMarketplaceFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const feeSeller = "10";
        const addressReceiceFee = owner.address;
        const addressTokenBase = "0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3";

        const Marketplace = await ethers.getContractFactory("ReMonsterMarketplace");
        const marketplace = await Marketplace.deploy(feeSeller, addressReceiceFee, addressTokenBase);
        marketplace.deployed();

        return { marketplace, feeSeller, addressReceiceFee, addressTokenBase, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should set the right feeSeller", async function () {
            const { marketplace, feeSeller } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.feeSeller()).to.equal(feeSeller);
        });

        it("Should set the right addressReceiceFee", async function () {
            const { marketplace, addressReceiceFee } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.addressReceiveFee()).to.equal(addressReceiceFee);
        });

        it("Should set the right addressTokenBase", async function () {
            const { marketplace, addressTokenBase } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.tokenBase()).to.equal(addressTokenBase);
        });

        it("Should set the right owner", async function () {
            const { marketplace, owner } = await loadFixture(deployMarketplaceFixture);

            expect(await marketplace.owner()).to.equal(owner.address);
        });
    });

    describe("setDecimalsFee", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called from another account", async function () {
                const { marketplace, otherAccount } = await loadFixture(
                    deployMarketplaceFixture
                );

                // We use marketplace.connect() to send a transaction from another account
                await expect(marketplace.connect(otherAccount).setDecimalsFee(18)).to.be.rejected;
            });

            it("Shouldn't fail if the setDecimalsFee has arrived and the owner calls it", async function () {
                const { marketplace, owner } = await loadFixture(
                    deployMarketplaceFixture
                );

                await expect(marketplace.connect(owner).setDecimalsFee(18)).not.to.be.reverted;
            });
        });
    });
    describe("setFeeSeller", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called from another account", async function () {
                const { marketplace, otherAccount, feeSeller } = await loadFixture(
                    deployMarketplaceFixture
                );

                // We use marketplace.connect() to send a transaction from another account
                await expect(marketplace.connect(otherAccount).setFeeSeller(feeSeller)).to.be.rejected;
            });

            it("Shouldn't fail if the setFeeSeller has arrived and the owner calls it", async function () {
                const { marketplace, owner, feeSeller } = await loadFixture(
                    deployMarketplaceFixture
                );

                await expect(marketplace.connect(owner).setFeeSeller(feeSeller)).not.to.be.reverted;
            });
        });

        describe("Events", function () {
            it("Should emit an event on setFeeSeller", async function () {
                const { marketplace, owner, feeSeller } = await loadFixture(
                    deployMarketplaceFixture
                );


                await expect(marketplace.connect(owner).setFeeSeller(feeSeller))
                    .to.emit(marketplace, "ChangedFeeSeller")
                    .withArgs(feeSeller);
            });
        });
    });

    describe("setNewAddressFee", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called from another account", async function () {
                const { marketplace, otherAccount, addressReceiceFee } = await loadFixture(
                    deployMarketplaceFixture
                );

                // We use marketplace.connect() to send a transaction from another account
                await expect(marketplace.connect(otherAccount).setNewAddressFee(addressReceiceFee)).to.be.rejected;
            });

            it("Shouldn't fail if the setNewAddressFee has arrived and the owner calls it", async function () {
                const { marketplace, owner, addressReceiceFee } = await loadFixture(
                    deployMarketplaceFixture
                );

                await expect(marketplace.connect(owner).setNewAddressFee(addressReceiceFee)).not.to.be.reverted;
            });
        });

        describe("Events", function () {
            it("Should emit an event on setFeeSeller", async function () {
                const { marketplace, owner, addressReceiceFee } = await loadFixture(
                    deployMarketplaceFixture
                );


                await expect(marketplace.connect(owner).setNewAddressFee(addressReceiceFee))
                    .to.emit(marketplace, "ChangedAddressReceiveSeller")
                    .withArgs(addressReceiceFee);
            });
        });
    });
});
