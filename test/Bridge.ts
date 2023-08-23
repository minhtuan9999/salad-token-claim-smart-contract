import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Training Item", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, userAddress] = await ethers.getSigners();

        const HashChipNFT = await ethers.getContractFactory("HashChipNFT");
        const hashChip = await HashChipNFT.connect(owner).deploy();
        hashChip.deployed();

        const Farm = await ethers.getContractFactory("ReMonsterFarm");
        const farm = await Farm.connect(owner).deploy("Farm", "FARM", 5000);
        farm.deployed();

        const Genesis = await ethers.getContractFactory("GenesisHash");
        const genesis = await Genesis.connect(owner).deploy();
        genesis.deployed();

        const Item = await ethers.getContractFactory("EhanceItem");
        const item = await Item.connect(owner).deploy("https://example.com/");
        item.deployed();

        const Bridge = await ethers.getContractFactory("BridgeHashChipOAS");
        const bridge = await Bridge.connect(owner).deploy(hashChip.address, genesis.address, farm.address, item.address);
        bridge.deployed();
        
        return {bridge, hashChip, farm, genesis, item, owner, userAddress };
    }

    describe("Test mint bath", function () {
        it('should check', async function () {
            const {bridge, hashChip, farm, genesis, item, owner, userAddress } = await loadFixture(deployERC721Fixture);
            let hashChipRole = await hashChip.MANAGEMENT_ROLE();
            let genesisRole = await farm.MANAGEMENT_ROLE();
            let farmRole = await genesis.MANAGEMENT_ROLE();
            let itemRole = await item.MANAGEMENT_ROLE();

            await hashChip.grantRole(hashChipRole, bridge.address);
            await farm.grantRole(farmRole, bridge.address);
            await genesis.grantRole(genesisRole, bridge.address);
            await item.grantRole(itemRole, bridge.address);

            await expect(bridge.connect(owner).bridgeHashChipNFT(userAddress.address, 1000, 1, 1)).not.to.be.reverted;

            console.log( await hashChip.getListTokensOfAddress(userAddress.address));
            console.log(await farm.getListFarmByAddress(userAddress.address));
            console.log(await genesis.boxOfAddress(userAddress.address, 1));
            console.log(await item.getListItemOfAddress(userAddress.address));

        });
    })
});
