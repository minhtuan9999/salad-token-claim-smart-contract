import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, network } from "hardhat";

describe("ReMonsterFarm", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployFarmFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Farm = await ethers.getContractFactory("ReMonsterFarm");
        const farm = await Farm.connect(owner).deploy("FARM", "FM", 1000);
        farm.deployed();

        return { farm, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should set the right name", async function () {
            const { farm } = await loadFixture(deployFarmFixture);
            expect(await farm.name()).to.equal("FARM");
        });

        it("Should set the right symbol", async function () {
            const { farm } = await loadFixture(deployFarmFixture);
            expect(await farm.symbol()).to.equal("FM");
        });
    });

    describe("setBaseURI", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called not from manager account", async function () {
                const { farm, otherAccount } = await loadFixture(deployFarmFixture);

                // We use farm.connect() to send a transaction from other account
                await expect(farm.connect(otherAccount).setBaseURI("")).to.be.rejected;
            });

            it("Shouldn't fail if the setBaseURI has arrived and the manager calls it", async function () {
                const { farm, owner } = await loadFixture(deployFarmFixture);

                // We use farm.connect() to send a transaction from other account
                await expect(farm.connect(owner).setBaseURI("")).not.to.be.rejected;
            });
        });
    });

    describe("createNFT", function () {
        describe("Validations", function () {
            it("Should revert with the right error if called not from manager account", async function () {
                const { farm, otherAccount } = await loadFixture(deployFarmFixture);

                // We use farm.connect() to send a transaction from other account
                await expect(farm.connect(otherAccount).createNFT(otherAccount.address, 0)).to.be.rejected;
            });

            it("Shouldn't fail if the createNFT has arrived and the manager calls it", async function () {
                const { farm, owner } = await loadFixture(deployFarmFixture);

                // We use farm.connect() to send a transaction from manager account
                await expect(farm.connect(owner).createNFT(owner.address, 0)).not.to.be.rejected;
            });

            describe("Events", function () {
                it("Should emit an event on createNFT", async function () {
                    const { farm, owner } = await loadFixture(deployFarmFixture);

                    // We use farm.connect() to send a transaction from manager account
                    await expect(farm.connect(owner).createNFT(owner.address, 0)).to.emit(farm, "NewFarm");
                    // .withArgs(ownerNFT.address);
                });
            });
        });
    });

    // describe("removeAsset", function () {
    //     describe("Validations", function () {
    //         it("Should revert with the right error if called not from manager", async function () {
    //             const { shop, farm, owner, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // Time travelling to the future!
    //             await network.provider.request({
    //                 method: 'evm_increaseTime',
    //                 params: [100],
    //             });

    //             // We use shop.connect() to send a transaction from ownerOAS account
    //             await expect(shop.connect(ownerOAS).removeAsset(farm.address, 0)).to.be.rejected;
    //         });

    //         it("Should revert with the right error if asset not exists", async function () {
    //             const { shop, farm, owner } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             // We use shop.connect() to send a transaction from owner account
    //             await expect(shop.connect(owner).removeAsset(farm.address, 0)).to.be.rejectedWith('ReMonsterShop::removeAsset: Asset not exist');
    //         });

    //         it("Shouldn't fail if the removeAsset has arrived and ADMIN calls it", async function () {
    //             const { shop, farm, owner, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // Time travelling to the future!
    //             await network.provider.request({
    //                 method: 'evm_increaseTime',
    //                 params: [100],
    //             });

    //             await expect(shop.connect(owner).removeAsset(farm.address, 0)).not.to.be.rejected;
    //         });
    //     });

    //     describe("Events", function () {
    //         it("Should emit an event on removeAsset", async function () {
    //             const { shop, farm, owner } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // We use shop.connect() to send a transaction from owner account
    //             await expect(shop.connect(owner).removeAsset(farm.address, 0)).to.emit(shop, "RemoveAssetSuccessful")
    //             // .withArgs(ownerNFT.address);
    //         });
    //     });
    // });

    // describe("buyItem", function () {
    //     describe("Validations", function () {
    //         it("Should revert with the right error if asset is not listed for sale yet ", async function () {
    //             const { shop, farm, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             // We use shop.connect() to send a transaction from ownerOAS account
    //             await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset not exists');
    //         });

    //         it("Should revert with the right error if asset not started", async function () {
    //             const { shop, farm, owner, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // We use shop.connect() to send a transaction from ownerOAS account
    //             await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset not started');
    //         });


    //         it("Should revert with the right error if asset ended", async function () {
    //             const { shop, farm, owner, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // Time travelling to the future!
    //             await network.provider.request({
    //                 method: 'evm_increaseTime',
    //                 params: [500],
    //             });

    //             // We use shop.connect() to send a transaction from ownerOAS account
    //             await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.be.rejectedWith('ReMonsterShop::buyAsset: Asset ended');
    //         });


    //     });

    //     describe("Events", function () {
    //         it("Should emit an event on buyAsset ", async function () {
    //             const { shop, farm, test20, owner, ownerOAS } = await loadFixture(
    //                 deployShopFixture
    //             );

    //             const timeStart = (await time.latest()) + 100;
    //             const timeEnd = timeStart + 300;

    //             // We use shop.connect() to send a transaction from owner account
    //             await shop.connect(owner).createAsset(farm.address, 0, "99000000000000000000", timeStart, timeEnd);

    //             // Time travelling to the future!
    //             await network.provider.request({
    //                 method: 'evm_increaseTime',
    //                 params: [100],
    //             });

    //             // Appprove OAS to contract shop
    //             await expect(test20.connect(ownerOAS).approve(shop.address, "1000000000000000000000000000000000000000000")).not.to.be.reverted;

    //             // We use shop.connect() to send a transaction from ownerOAS account
    //             await expect(shop.connect(ownerOAS).buyItem(farm.address, 0, 1)).to.emit(shop, "BuyAssetSuccessful")
    //             // .withArgs(ownerNFT.address);
    //         });
    //     });
    // });
});
