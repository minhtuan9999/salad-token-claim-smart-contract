import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { utils } from "ethers";

describe("Trainer license", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721Fixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, userAddress, treasuryAddress] = await ethers.getSigners();
    const Trainer = await ethers.getContractFactory("TrainerLicense");
    const trainer = await Trainer.connect(owner).deploy();
    trainer.deployed();
    return {
      trainer,
      owner,
      userAddress,
    };
  }

  describe("Deployment", function () {
    it("should deploy and set the owner correctly", async function () {
      const { trainer, owner } = await loadFixture(deployERC721Fixture);
      expect(await trainer.owner()).to.equal(owner.address);
    });
  });

  describe("Mint trainer", function () {
    it("Should check function: mint trainer", async function () {
      const { trainer, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      await expect(trainer.connect(owner).mintTrainerLicense(owner.address)).not.to.be.reverted;
      await expect(trainer.connect(userAddress).mintTrainerLicense(owner.address)).to.be.reverted;
    });
    
    it("Should check event: mint trainer", async function () {
      const { trainer, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      let tx1 = await trainer.connect(owner).mintTrainerLicense(owner.address);
      const receipt1 = await tx1.wait();
      let token1;
      if (receipt1 && receipt1.events) {
        const events = receipt1.events;
        const createEvent = events.find(
          (event) => event.event === "MintTrainerLicense"
        );
        if (createEvent && createEvent.args) {
          token1 = createEvent.args?.tokenId.toString();
        }
      }
      expect(await trainer.connect(owner).ownerOf(token1)).to.equals(
        owner.address
      );
    });
  });

  describe("burn TrainerLicens", function () {
    it("Should check function: burnTrainerLicense", async function () {
      const { trainer, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      const tokenId = await trainer.connect(owner).mintTrainerLicense(owner.address);      
      await expect(trainer.connect(owner).burnTrainerLicense( tokenId.value.toNumber())).not.to.be.reverted;
    });
  });
 
});
