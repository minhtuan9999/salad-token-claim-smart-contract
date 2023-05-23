import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Remonster: ERC721", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.

    async function deployERC721Fixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount1, ownerNFT, ownerOAS] = await ethers.getSigners();

        const MonsterErc721 = await ethers.getContractFactory("Monster");
        const monster = await MonsterErc721.connect(owner).deploy("ReMonster", "RMT");
        monster.deployed();

        return { monster, owner, otherAccount1, ownerNFT, ownerOAS };
    }

    describe("Remonster: Monsterssssss", function () {
        it("Should set the right feeSeller", async function () {
            const { monster} = await loadFixture(deployERC721Fixture);
            
        });
    });
});
