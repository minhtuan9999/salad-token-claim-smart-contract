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
        const [owner, managerAccount, ownerOAS] = await ethers.getSigners();

        const totalSupply = "100000000000000000000000000000";
        const addressReceice = owner.address;

        const Test20 = await ethers.getContractFactory("Test20");
        const test20 = await Test20.connect(ownerOAS).deploy(totalSupply);
        test20.deployed();

        const Shop = await ethers.getContractFactory("ReMonsterShop");
        const shop = await Shop.connect(owner).deploy(addressReceice, test20.address);
        shop.deployed();

        const Farm = await ethers.getContractFactory("ReMonsterFarm");
        const farm = await Farm.connect(owner).deploy("ReMonsterFarm", "FM");
        farm.deployed();

        // Set role manager to SHOP
        await farm.connect(owner).grantRole(farm.MANAGERMENT_ROLE(), shop.address)

        return { test20, shop, farm, addressReceice, owner, managerAccount, ownerOAS };
    }

    describe("Deployment", function () {
        it("Should set the right addressReceice", async function () {
            const { shop, addressReceice } = await loadFixture(deployShopFixture);

            expect(await shop.addressReceive()).to.equal(addressReceice);
        });

        it("Should set the right addressTokenBase", async function () {
            const { shop, test20 } = await loadFixture(deployShopFixture);

            expect(await shop.tokenBase()).to.equal(test20.address);
        });
    });

    describe("setNewAddressFee", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called from ownerOAS account", async function () {
                const { shop, ownerOAS, addressReceice } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).setNewAddress(addressReceice)).to.be.rejected;
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

                const timeStart = parseInt(String((await time.latest()) / 1000)) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(shop.address, 0, "99000000000000000000", timeStart, timeEnd)).to.be.revertedWith('ReMonsterShop::createAsset: Unsupported contract');
            });

            it("Should revert with the right error if called not from manager ", async function () {
                const { shop, farm, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = parseInt(String((await time.latest()) / 1000)) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).to.be.reverted;
            });

            it("Should revert with the right error if asset already exists", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);
                await expect(shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).to.be.rejectedWith('ReMonsterShop::createAsset: Asset already exists');
            });

            it("Should revert with the right error if price less than or equal to 0", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, 0, "0", timeStart, timeEnd)).to.be.rejectedWith('ReMonsterShop::createAsset: Price should be bigger than 0');
            });

            it("Should revert with the right error if start time is not now or in the future", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) - 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).to.be.rejectedWith('ReMonsterShop::createAsset: Start time must be now or in the future');
            });

            it("Should revert with the right error if time start after time end", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeEnd = (await time.latest()) + 100;
                const timeStart = timeEnd + 300;

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).to.be.rejectedWith('ReMonsterShop::createAsset: Start time must be before end time');
            });

            it("Shouldn't fail if the createAsset has arrived and the owner calls it", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).not.to.be.rejected;

            });

            describe("Events", function () {
                it("Should emit an event on createAsset", async function () {
                    const { shop, farm, owner } = await loadFixture(
                        deployShopFixture
                    );

                    const timeStart = (await time.latest()) + 100;
                    const timeEnd = timeStart + 300;

                    // We use shop.connect() to send a transaction from owner account
                    await expect(shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd)).to.emit(shop, "NewAssetSuccessful")
                    // .withArgs(ownerNFT.address);
                });
            });
        });
    });

    describe("removeAsset", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called not from manager", async function () {
                const { shop, farm, owner, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // Time travelling to the future!
                await network.provider.request({
                    method: 'evm_increaseTime',
                    params: [100],
                });

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).removeAsset(farm.address, 0)).to.be.rejected;
            });

            it("Should revert with the right error if asset not exists", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).removeAsset(farm.address, 0)).to.be.rejectedWith('ReMonsterShop::removeAsset: Asset not exist');
            });

            it("Shouldn't fail if the removeAsset has arrived and ADMIN calls it", async function () {
                const { shop, farm, owner, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // Time travelling to the future!
                await network.provider.request({
                    method: 'evm_increaseTime',
                    params: [100],
                });

                await expect(shop.connect(owner).removeAsset(farm.address, 0)).not.to.be.rejected;
            });
        });

        describe("Events", function () {
            it("Should emit an event on removeAsset", async function () {
                const { shop, farm, owner } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // We use shop.connect() to send a transaction from owner account
                await expect(shop.connect(owner).removeAsset(farm.address, 0)).to.emit(shop, "RemoveAssetSuccessful")
                // .withArgs(ownerNFT.address);
            });
        });
    });

    describe("buyItem", function () {
        describe("Validations", function () {
            it("Should revert with the right error if asset is not listed for sale yet ", async function () {
                const { shop, farm, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset not exists');
            });

            it("Should revert with the right error if asset not started", async function () {
                const { shop, farm, owner, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset not started');
            });


            it("Should revert with the right error if asset ended", async function () {
                const { shop, farm, owner, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // Time travelling to the future!
                await network.provider.request({
                    method: 'evm_increaseTime',
                    params: [500],
                });

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset ended');
            });


        });

        describe("Events", function () {
            it("Should emit an event on buyAsset ", async function () {
                const { shop, farm, test20, owner, ownerOAS } = await loadFixture(
                    deployShopFixture
                );

                const timeStart = (await time.latest()) + 100;
                const timeEnd = timeStart + 300;

                // We use shop.connect() to send a transaction from owner account
                await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

                // Time travelling to the future!
                await network.provider.request({
                    method: 'evm_increaseTime',
                    params: [100],
                });

                // Appprove OAS to contract shop
                await expect(test20.connect(ownerOAS).approve(shop.address, "1000000000000000000000000000000000000000000")).not.to.be.reverted;

                // We use shop.connect() to send a transaction from ownerOAS account
                await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.emit(shop, "BuyAssetSuccessful")
                // .withArgs(ownerNFT.address);
            });
        });
    });
});
