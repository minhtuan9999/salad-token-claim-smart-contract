// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./MonsterBase.sol";

interface IGeneralHash {
    function burn(uint256 _tokenId) external;
}

interface IGenesisHash {
    function burn(uint256 _tokenId) external;
}

interface IHashChip {
    function burn(address _from, uint256 _id, uint256 _amount) external;
}

interface IToken {
    function burnToken(address account, uint256 amount) external;
}

interface IMonsterMemory {
    function mint(address _address, uint256 _monsterId) external;
}

interface IRegenerationItem {
    function burn(address _from, uint256 _id, uint256 _amount) external;

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external;
    function isMintMonster(uint256 _itemId) external view returns(bool);
}
interface IFusionItem {
    function burn(address _from, uint256 _id, uint256 _amount) external;

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external;
}
interface ITreasuryContract {
    function deposit(uint256 totalAmount) external payable;
}
contract MonsterInterface is MonsterBase {
    IToken public tokenBaseContract;
    IERC721 public externalNFTContract;
    IGenesisHash public genesisHashContract;
    IGeneralHash public generalHashContract;
    IERC721 public hashChipNFTContract;
    IMonsterMemory public monsterMemory;
    IRegenerationItem public regenerationItem;
    IFusionItem public fusionItem;
    ITreasuryContract public treasuryContract;

    // Set contract token OAS
    function initSetTokenBaseContract(
        IToken _tokenBase
    ) external onlyRole(MANAGEMENT_ROLE) {
        tokenBaseContract = _tokenBase;
    }

    // Set contract External NFT
    function initSetExternalContract(
        IERC721 externalNFT
    ) external onlyRole(MANAGEMENT_ROLE) {
        externalNFTContract = externalNFT;
    }

    // Set contract General Hash
    function initSetGeneralHashContract(
        IGeneralHash generalHash
    ) external onlyRole(MANAGEMENT_ROLE) {
        generalHashContract = generalHash;
    }

    // Set contract Genesis Hash
    function initSetGenesisHashContract(
        IGenesisHash genesisHash
    ) external onlyRole(MANAGEMENT_ROLE) {
        genesisHashContract = genesisHash;
    }

    // Set contract Hash Chip NFT
    function initSetHashChipContract(
        IERC721 hashChip
    ) external onlyRole(MANAGEMENT_ROLE) {
        hashChipNFTContract = hashChip;
    }

    // Set contract Monster memory
    function initSetMonsterMemoryContract(
        IMonsterMemory _monsterMemory
    ) external onlyRole(MANAGEMENT_ROLE) {
        monsterMemory = _monsterMemory;
    }

    // Set contract Monster Item
    function initSetRegenerationContract(
        IRegenerationItem _regenerationItem
    ) external onlyRole(MANAGEMENT_ROLE) {
        regenerationItem = _regenerationItem;
    }

    // Set contract Fusion Item
    function initSetFusionContract(
        IFusionItem _fusionItem
    ) external onlyRole(MANAGEMENT_ROLE) {
        fusionItem = _fusionItem;
    }

    // Set Treasury contract
    function initSetTreasuryContract(
        ITreasuryContract _treasuryContract
    ) external onlyRole(MANAGEMENT_ROLE) {
        treasuryContract = _treasuryContract;
    }
}
