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

  // type 0: EXTERNAL_NFT
  // type 1: GENESIS_HASH
  // type 2: GENERAL_HASH
  // type 3: HASH_CHIP_NFT
  // type 4: REGENERATION_ITEM
  // type 5: FREE
  enum TypeMint {
    EXTERNAL_NFT,
    GENESIS_HASH,
    GENERAL_HASH,
    HASH_CHIP_NFT,
    REGENERATION_ITEM,
    FREE,
    FUSION,
  }
  const provider = ethers.provider;
  const cost = 1000;
  async function signMessage(signer: Signer, message: string): Promise<string> {
    const signature = await signer.signMessage(utils.arrayify(message));
    return signature;
  }
  async function deployERC721Fixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, userAddress, treasuryAddress] = await ethers.getSigners();

    const Accessories = await ethers.getContractFactory("Accessories");
    const accessories = await Accessories.connect(owner).deploy();
    accessories.deployed();

    const Coach = await ethers.getContractFactory("Coach");
    const coach = await Coach.connect(owner).deploy();
    coach.deployed();

    const GeneralHash = await ethers.getContractFactory("GeneralHash");
    const generalHash = await GeneralHash.connect(owner).deploy();
    generalHash.deployed();

    const GenesisHash = await ethers.getContractFactory("GenesisHash");
    const genesisHash = await GenesisHash.connect(owner).deploy();
    genesisHash.deployed();

    const MonsterCrystal = await ethers.getContractFactory("MonsterCrystal");
    const monsterCrystal = await MonsterCrystal.connect(owner).deploy();
    monsterCrystal.deployed();

    const MonsterMemory = await ethers.getContractFactory("MonsterMemory");
    const monsterMemory = await MonsterMemory.connect(owner).deploy();
    monsterMemory.deployed();

    const Monster = await ethers.getContractFactory("Monster");
    const monster = await Monster.connect(owner).deploy();
    monster.deployed();

    const Skin = await ethers.getContractFactory("Skin");
    const skin = await Skin.connect(owner).deploy();
    skin.deployed();

    const RemonsterItem = await ethers.getContractFactory("RemonsterItem");
    const remonsterItem = await RemonsterItem.connect(owner).deploy(
      "https://example.com/"
    );
    remonsterItem.deployed();

    const TokenXXX = await ethers.getContractFactory("TokenXXX");
    const tokenXXX = await TokenXXX.connect(owner).deploy("XXX", "XXX");
    tokenXXX.deployed();

    const ExternalNFT = await ethers.getContractFactory("Test721");
    const externalNFT = await ExternalNFT.connect(owner).deploy();
    externalNFT.deployed();

    const HashChipNFT = await ethers.getContractFactory("HashChipNFT");
    const hashChip = await HashChipNFT.connect(owner).deploy();
    hashChip.deployed();

    return {
      hashChip,
      accessories,
      coach,
      monster,
      monsterCrystal,
      monsterMemory,
      generalHash,
      genesisHash,
      skin,
      owner,
      userAddress,
      remonsterItem,
      tokenXXX,
      externalNFT,
      treasuryAddress,
    };
  }

  describe("Deployment", function () {
    it("should deploy and set the owner correctly", async function () {
      const { monster, owner } = await loadFixture(deployERC721Fixture);
      expect(await monster.owner()).to.equal(owner.address);
    });
  });
  describe("Mint from  Free NFT", function () {
    it("Should check function: mint NFT Free", async function () {
      const { monster, monsterMemory, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      await expect(monster.connect(owner).mintMonsterFree()).not.to.be.reverted;
      await expect(monster.connect(owner).mintMonsterFree()).to.be.revertedWith(
        "Monster:::MonsterCore::_fromFreeNFT: You have created free NFT"
      );
    });
    it("Should check event: mint NFT Free", async function () {
      const { monster, monsterMemory, owner, userAddress } = await loadFixture(
        deployERC721Fixture
      );
      let tx1 = await monster.connect(userAddress).mintMonsterFree();
      const receipt1 = await tx1.wait();
      let token1;
      if (receipt1 && receipt1.events) {
        const events = receipt1.events;
        const createEvent = events.find(
          (event) => event.event === "createNFTMonster"
        );
        if (createEvent && createEvent.args) {
          token1 = createEvent.args?.tokenId.toString();
        }
      }
      expect(await monster.connect(userAddress).ownerOf(token1)).to.equals(
        userAddress.address
      );
    });
  });

  
});
