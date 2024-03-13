import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { utils } from "ethers";

describe("Trophies license", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721Fixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, userAddress, treasuryAddress] = await ethers.getSigners();
    const Trophies = await ethers.getContractFactory("Trophies");
    const trophies = await Trophies.connect(owner).deploy();
    trophies.deployed();
    return {
      trophies,
      owner,
      userAddress,
    };
  }

  describe("Deployment", function () {
    it("should deploy and set the owner correctly", async function () {
      const { trophies, owner } = await loadFixture(deployERC721Fixture);
      expect(await trophies.owner()).to.equal(owner.address);
    });
  });

  describe("Mint trophies", function () {
    it("Should check function: mint trophies", async function () {
      const { trophies, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      await expect(trophies.connect(owner).mintTrophies(owner.address, 1)).not.to.be.reverted;
      await expect(trophies.connect(userAddress).mintTrophies(owner.address, 1)).to.be.reverted;
    });
    
    it("Should check event: mint trophies", async function () {
      const { trophies, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      let tx1 = await trophies.connect(owner).mintTrophies(owner.address, 1);
      const receipt1 = await tx1.wait();
      let token1;
      if (receipt1 && receipt1.events) {
        const events = receipt1.events;
        const createEvent = events.find(
          (event) => event.event === "MintTrophies"
        );
        if (createEvent && createEvent.args) {
          token1 = createEvent.args?.tokenId.toString();
        }
      }
      expect(await trophies.connect(owner).ownerOf(token1)).to.equals(
        owner.address
      );
    });
  });

  describe("burn Trophies", function () {
    it("Should check function: burnTrophies", async function () {
      const { trophies, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      const tokenId = await trophies.connect(owner).mintTrophies(owner.address, 1);      
      await expect(trophies.connect(owner).burnTrophies( tokenId.value.toNumber())).not.to.be.reverted;
    });
  });
 
});
