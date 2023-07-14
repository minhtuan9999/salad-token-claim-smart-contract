import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, network } from "hardhat";

describe("ReMonsterShop", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployShopFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, managerAccount, otherAccount1] = await ethers.getSigners();

        const addressReceice = owner.address;

        const Shop = await ethers.getContractFactory("ReMonsterShop");
        const shop = await Shop.connect(owner).deploy(addressReceice);
        shop.deployed();

        const Farm = await ethers.getContractFactory("ReMonsterFarm");
        const farm = await Farm.connect(owner).deploy("ReMonsterFarm", "FM");
        farm.deployed();

        // Set role manager to SHOP
        await farm.connect(owner).grantRole(farm.MANAGERMENT_ROLE(), shop.address)

        return { shop, farm, addressReceice, owner, managerAccount, otherAccount1 };
    }

    describe("Deployment", function () {
        it("Should set the right addressReceice", async function () {
            const { shop, addressReceice } = await loadFixture(deployShopFixture);

            expect(await shop.addressReceive()).to.equal(addressReceice);
        });
    });

    describe("setNewAddressFee", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called from otherAccount1 account", async function () {
                const { shop, otherAccount1, addressReceice } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from otherAccount1
                await expect(shop.connect(otherAccount1).setNewAddress(addressReceice)).to.be.rejected;
            });

            it("Shouldn't fail if the setNewAddress has arrived and the owner calls it", async function () {
                const { shop, owner, addressReceice } = await loadFixture(
                    deployShopFixture
                );

                await expect(shop.connect(owner).setNewAddress(addressReceice)).not.to.be.reverted;
            });
        });

        describe("Events", function () {
            it("Should emit an event on setNewAddressFee", async function () {
                const { shop, owner, addressReceice } = await loadFixture(
                    deployShopFixture
                ); deployShopFixture


                await expect(shop.connect(owner).setNewAddress(addressReceice))
                    .to.emit(shop, "ChangedAddressReceive")
                    .withArgs(addressReceice);
            });
        });
    });

    describe("createAsset", function () {
        describe("Validations", function () {
            it("Should revert with the right error if the contract address is not valid", async function () {
                const { shop, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(shop.address, "99000000000000000000")).to.be.revertedWith('ReMonsterShop::createAsset: Unsupported contract');
            });

            it("Should revert with the right error if called not from manager ", async function () {
                const { shop, farm, otherAccount1 } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from otherAccount1
                await expect(shop.connect(otherAccount1).createAsset(farm.address, "99000000000000000000")).to.be.reverted;
            });

            it("Should revert with the right error if asset already exists", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, "99000000000000000000");
                await expect(shop.connect(owner).createAsset(farm.address, "99000000000000000000")).to.be.rejectedWith('ReMonsterShop::createAsset: Asset already exists');
            });

            it("Should revert with the right error if price less than or equal to 0", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, "0")).to.be.rejectedWith('ReMonsterShop::createAsset: Price should be bigger than 0');
            });


            it("Shouldn't fail if the createAsset has arrived and the owner calls it", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, "99000000000000000000")).not.to.be.rejected;

            });

            describe("Events", function () {
                it("Should emit an event on createAsset", async function () {
                    const { shop, farm, owner } = await loadFixture(
                        deployShopFixture
                    );

                    // We use shop.connect() to send a transaction from owner account
                    await expect(shop.connect(owner).createAsset(farm.address, "99000000000000000000")).to.emit(shop, "NewAssetSuccessful")
                    // .withArgs(ownerNFT.address);
                });
            });
        });
    });

    describe("removeAsset", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called not from manager", async function () {
                const { shop, farm, owner, otherAccount1 } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, "99000000000000000000");

                // Time travelling to the future!
                await network.provider.request({
                    method: 'evm_increaseTime',
                    params: [100],
                });

                // We use shop.connect() to send a transaction from otherAccount1
                await expect(shop.connect(otherAccount1).removeAsset(farm.address)).to.be.rejected;
            });

            it("Should revert with the right error if asset not exists", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).removeAsset(farm.address)).to.be.rejectedWith('ReMonsterShop::removeAsset: Asset not exist');
            });

            it("Shouldn't fail if the removeAsset has arrived and ADMIN calls it", async function () {
                const { shop, farm, owner, otherAccount1 } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, "99000000000000000000");

                // Time travelling to the future!
                // await network.provider.request({
                //     method: 'evm_increaseTime',
                //     params: [100],
                // });

                await expect(shop.connect(owner).removeAsset(farm.address)).not.to.be.rejected;
            });
        });

        describe("Events", function () {
            it("Should emit an event on removeAsset", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, "99000000000000000000");

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).removeAsset(farm.address)).to.emit(shop, "RemoveAssetSuccessful")
                // .withArgs(ownerNFT.address);
            });
        });
    });

    describe("buyItem", function () {
        describe("Validations", function () {
            it("Should revert with the right error if asset is not listed for sale yet ", async function () {
                const { shop, farm, otherAccount1 } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from otherAccount1
                await expect(shop.connect(otherAccount1).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset not exists');
            });

            it("Shouldn't fail if the buyItem has arrived and the otherAccount1 calls it", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, "99000000000000000000")).not.to.be.rejected;

            });

        });

        describe("Events", function () {
            it("Should emit an event on buyAsset ", async function () {
                const { shop, farm, owner, otherAccount1 } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, "99000000000000000000");
                
                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(otherAccount1).buyItem(farm.address, 0, 1)).to.emit(shop, "BuyAssetSuccessful")
                // .withArgs(ownerNFT.address);
            });
        });
    });
});
