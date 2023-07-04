// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./MonsterBase.sol";

interface IGeneralHash {
    function burn(uint256 _tokenId) external;
}

interface IGenesisHash {
    function refreshTheNumberOfUse(uint256 _tokenId) external;

    function countRegeneration(
        uint256 _tokenId
    ) external view returns (uint256);
}

interface IERC1155Item {
    function burn(address _from, uint256 _id, uint256 _amount) external;
}

interface IHashChip {
    function burn(address _from, uint256 _id, uint256 _amount) external;
}

interface IToken {
    function burnToken(address account, uint256 amount) external;
}

interface IMonsterMemory {
    // mint monster memory
    function mint(address _address, uint256 _monsterId) external;
}

interface IMonsterItem {
    // burn item from tokenid
    function burn(address _from, uint256 _id, uint256 _amount) external;

    function mint(
        address _addressTo,
        uint256 _itemType,
        uint256 _collectionType,
        uint256 _number,
        bytes memory _data
    ) external;

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external;
}

contract MonsterInterface is MonsterBase {
    IToken tokenBaseContract;
    IERC721 externalNFTContract;
    IGenesisHash genesisHashContract;
    IGeneralHash generalHashContract;
    IERC721 hashChipNFTContract;
    IERC1155Item regenerationContract;
    IMonsterMemory monsterMemory;
    IMonsterItem item;

    // Set contract token OAS
    function initSetTokenBase(
        IToken _tokenBase
    ) external onlyRole(MANAGERMENT_ROLE) {
        tokenBaseContract = _tokenBase;
    }

    // Set contract External NFT
    function initSetExternalNFT(
        IERC721 externalNFT
    ) external onlyRole(MANAGERMENT_ROLE) {
        externalNFTContract = externalNFT;
    }

    // Set contract General Hash
    function initSetGeneralHash(
        IGeneralHash generalHash
    ) external onlyRole(MANAGERMENT_ROLE) {
        generalHashContract = generalHash;
    }

    // Set contract Genesis Hash
    function initSetGenesisHash(
        IGenesisHash genesisHash
    ) external onlyRole(MANAGERMENT_ROLE) {
        genesisHashContract = genesisHash;
    }

    // Set contract Genesis Hash
    function initSetRegenerationItem(
        IERC1155Item _regenerationContract
    ) external onlyRole(MANAGERMENT_ROLE) {
        regenerationContract = _regenerationContract;
    }

    // Set contract Hash Chip NFT
    function initSetHashChip(IERC721 hashChip) external onlyRole(MANAGERMENT_ROLE) {
        hashChipNFTContract = hashChip;
    }

    // Set contract Monster memory
    function initSetMonsterMemory(
        IMonsterMemory _monsterMemory
    ) external onlyRole(MANAGERMENT_ROLE) {
        monsterMemory = _monsterMemory;
    }

    // Set contract Monster Item
    function initSetMonsterItem(
        IMonsterItem _monsterItem
    ) external onlyRole(MANAGERMENT_ROLE) {
        item = _monsterItem;
    }
}
