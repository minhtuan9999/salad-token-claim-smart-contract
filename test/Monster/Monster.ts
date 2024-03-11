import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { utils } from "ethers";

describe("Monster Managerment", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721Fixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, userAddress, treasuryAddress] = await ethers.getSigners();
    const Monster = await ethers.getContractFactory("Monster");
    const monster = await Monster.connect(owner).deploy();
    monster.deployed();
    return {
      monster,
      owner,
      userAddress,
    };
  }

  describe("Deployment", function () {
    it("should deploy and set the owner correctly", async function () {
      const { monster, owner } = await loadFixture(deployERC721Fixture);
      expect(await monster.owner()).to.equal(owner.address);
    });
  });

  describe("Mint monster", function () {
    it("Should check function: mint monster", async function () {
      const { monster, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      await expect(monster.connect(owner).mintMonster(owner.address, 1)).not.to.be.reverted;
      await expect(monster.connect(userAddress).mintMonster(owner.address, 1)).to.be.reverted;
    });
    it("Should check function: mint monster free", async function () {
      const { monster, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      await expect(monster.connect(userAddress).mintMonster(owner.address, 1)).to.be.reverted;
      await expect(monster.connect(owner).mintMonster(owner.address, 5)).not.to.be.reverted;
      await expect(monster.connect(owner).mintMonster(owner.address, 5)).to.be.revertedWith("You owned free NFT");
    });
    it("Should check event: mint monster", async function () {
      const { monster, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      let tx1 = await monster.connect(owner).mintMonster(owner.address, 1);
      const receipt1 = await tx1.wait();
      let token1;
      if (receipt1 && receipt1.events) {
        const events = receipt1.events;
        const createEvent = events.find(
          (event) => event.event === "MintMonster"
        );
        if (createEvent && createEvent.args) {
          token1 = createEvent.args?.tokenId.toString();
        }
      }
      expect(await monster.connect(owner).ownerOf(token1)).to.equals(
        owner.address
      );
    });
  });

  describe("SetStatus monster", function () {
    it("Should check function: setStatus monster", async function () {
      const { monster, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      const tokenId = await monster.connect(owner).mintMonster(owner.address, 1);
      await expect(monster.connect(owner).setStatusMonster(Number(tokenId), true)).not.to.be.reverted;
    });
  });
 
});
