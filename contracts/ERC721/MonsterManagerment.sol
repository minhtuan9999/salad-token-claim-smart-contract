// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface Monster {
    //fusion monster
    function fusionNFT(address _address, uint256 _firstTokenId, uint256 _lastTokenId) external returns(uint256);
    // fusion Regeneration nft
    function fusionRegeneration(address _address) external returns(uint256);
    //burn monster
    function burnMonster(uint256 _tokenId) external ;
    //get lifeSpan monster
    function getStatusMonster(uint256 tokenId) external view returns(bool);
    // check monster is free?
    function isFreeMonster(uint256 tokenId) external view returns(bool);
    function createNFT(address _address) external returns (uint256);
}
interface MonsterMemory {
    function mintMonsterMemory(address _address) external returns(uint256);
}
interface Coach {
    function mintCoach(
        address _address,
        bool _status
    ) external returns(uint256);
}
interface MonsterCrystal {
    function mintMonsterCrystal(
        address _address,
        bool _status
    ) external returns(uint256);
    function burnMonsterCrystal(uint256 _tokenId) external;
}
interface GenesisHash {
    function burnGenesisHash(uint256 _tokenId) external;
}
interface GeneralHash {
    function burnGeneralHash(uint256 _tokenId) external;
    function fusionRegeneration(uint256 _tokenId) external;
}
interface Accessories {
    function mintAccessories(
        address _address
    ) external returns (uint256);
}
contract MonsterManagerment is Ownable,ReentrancyGuard, AccessControl, Pausable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // stored current packageId
    Counters.Counter private _tokenIds;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    
    constructor() {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
    }
    
    //STRUCT of generalHash contract
    struct generalHash{
        uint256 numberRegeneration;
    }
    // limit fusion Regeneration general hash
    uint256 private  limitRegeneration;
    //mapping 
    // monster lifeSpan == false => mint monster memory
    event fusionNFTMonster(address _owner,
                           uint256 _newMonster, uint256 _firstTokenId, uint256 _lastTokenId,
                           uint256 _newMonsterMemory                       
    );
    // monster lifeSpan == true => not mint monster memory
    event fusionNFTMonsterNotMemory(address _owner,
                           uint256 _newMonster, uint256 _firstTokenId, uint256 _lastTokenId                
    );
    // monster lifeSpan == false =>  mint monster memory + coach
    event createCoachByMonster(address _owner,
                           uint256 _newCoach, uint256 _tokenBurn,
                           uint256 _newMonsterMemory
                                          
    );
    // monster lifeSpan == false =>  mint monster memory + monster crystal
    event createCrystalByMonster(address _owner,
                           uint256 _newCrystal, uint256 _tokenBurn,
                           uint256 _newMonsterMemory
                                          
    );
    /*
     * fusion Regeneration
     * @param _owner: address of owner
     * @param _fistId: first tokenId of genesisHash
     * @param _lastId: last tokenId of genesisHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionGenesisHashNFT(address _owner,
                           uint256 _fistId, uint256 _lastId,
                           uint256 _newTokenId                                    
    );
/*
     * fusion Regeneration
     * @param _owner: address of owner
     * @param _fistId: first tokenId of generalHash
     * @param _lastId: last tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionGeneralHashNFT(address _owner,
                           uint256 _fistId, uint256 _lastId,
                           uint256 _newTokenId                                    
    );
    /*
     * fusion Regeneration
     * @param _owner: address of owner
     * @param _fistId: first tokenId of generalHash
     * @param _lastId: last tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionMultipleHashNFT(address _owner,
                           uint256 _genesisId, uint256 _generalId,
                           uint256 _newTokenId                                    
    );
    /* 
     * create Monster From Genesis hash
     * @param _owner: address of owner
     * @param _genesisAddress: first tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event createMonsterFromGenesis(address _owner,
                           uint256 _genesisAddress,
                           uint256 _newTokenId
    );
    /* 
     * create Monster From Genesis hash
     * @param _owner: address of owner
     * @param _generalAddress: first tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event createMonsterFromGeneral(address _owner,
                           uint256 _generalAddress,
                           uint256 _newTokenId
    );
   /*
     * fusion a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */
    function fusionMonsterNFT(address _monsterAddress,
                              address _monsterMemoryAddress,
                              address _owner,
                              uint256 _firstTokenId, 
                              uint256 _lastTokenId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 newTokenId = Monster(_monsterAddress).fusionNFT(_owner, _firstTokenId, _lastTokenId);
        bool lifeSpanFistMonster = Monster(_monsterAddress).getStatusMonster(_firstTokenId);
        bool lifeSpanLastMonster = Monster(_monsterAddress).getStatusMonster(_lastTokenId);
        if(lifeSpanFistMonster && lifeSpanLastMonster){
            // mint monster memory
            uint256 newMonsterMemory = MonsterMemory(_monsterMemoryAddress).mintMonsterMemory(_owner);
            emit fusionNFTMonster(_owner, newTokenId, _firstTokenId, _lastTokenId, newMonsterMemory);
        }else {
            emit fusionNFTMonsterNotMemory(_owner, newTokenId, _firstTokenId, _lastTokenId);
        }
    }

/*
     * Create coach from Monster
     * @param _monsterAddress: address of owner
     * @param _coachAddress: first tokenId fusion => burn
     * @param _monsterMemoryAddress: last tokenId fusion => burn
     * @param _owner: first tokenId fusion => burn
     * @param _idBurn: last tokenId fusion => burn
     */
    function createCoachNFT(address _monsterAddress,
                              address _coachAddress,
                              address _monsterMemoryAddress,
                              address _owner,
                              uint256 _idBurn
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        bool isStatusMonster = Monster(_monsterAddress).getStatusMonster(_idBurn);
        require(!isStatusMonster, "MonsterManagerment: createCoachNFT: The monster is alive");
        Monster(_monsterAddress).burnMonster(_idBurn);
        bool isFreeMonster = Monster(_monsterAddress).isFreeMonster(_idBurn);
        uint256 tokenId;
        if(isFreeMonster) {
            tokenId = Coach(_coachAddress).mintCoach(_owner, true);
        }else {
            tokenId = Coach(_coachAddress).mintCoach(_owner, false);
        }
        uint256 newMonsterMemory = MonsterMemory(_monsterMemoryAddress).mintMonsterMemory(_owner);
        emit createCoachByMonster(_owner, tokenId, _idBurn, newMonsterMemory);

    }

/*
     * Create crystal from Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */
    function createMonsterCrystalNFT(address _monsterAddress,
                              address _crystalAddress,
                              address _monsterMemoryAddress,
                              address _owner,
                              uint256 _idBurn
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        bool isStatusMonster = Monster(_monsterAddress).getStatusMonster(_idBurn);
        require(!isStatusMonster, "MonsterManagerment: createCoachNFT: The monster is alive");
        Monster(_monsterAddress).burnMonster(_idBurn);                
        bool isFreeMonster = Monster(_monsterAddress).isFreeMonster(_idBurn);
        uint256 tokenId;
        if(isFreeMonster) {
            tokenId = MonsterCrystal(_crystalAddress).mintMonsterCrystal(_owner, true);
        }else {
            tokenId = MonsterCrystal(_crystalAddress).mintMonsterCrystal(_owner, true);
        }
        uint256 newMonsterMemory = MonsterMemory(_monsterMemoryAddress).mintMonsterMemory(_owner);
        emit createCrystalByMonster(_owner, tokenId, _idBurn, newMonsterMemory);
    }

    /*
     * Create monster from fusion genersis hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _genesisAddress: address of genesis contract
     * @param _firstId: first tokenId fusion 
     * @param _lastId: last tokenId fusion 
     */
    function fusionGenesisHash(address _monsterAddress,
                                address _genesisAddress,
                                address _owner,
                                uint256 _firstId,
                                uint256 _lastId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(IERC721(_genesisAddress).ownerOf(_firstId) == _owner,
                "The owner is not correct"
        );
        require(IERC721(_genesisAddress).ownerOf(_lastId) == _owner,
                "The owner is not correct"
        );
        uint256 newTokenId = Monster(_monsterAddress).fusionRegeneration(_owner);
        emit fusionGenesisHashNFT(_owner, _firstId, _lastId, newTokenId);
    }

    /*
     * Create monster from fusion general hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _generalAddress: address of general contract
     * @param _firstId: first tokenId fusion 
     * @param _lastId: last tokenId fusion 
     */
    function fusionGeneralHash(address _monsterAddress,
                                address _generalAddress,
                                address _owner,
                                uint256 _firstId,
                                uint256 _lastId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(IERC721(_generalAddress).ownerOf(_firstId) == _owner,
                "The owner is not correct"
        );
        require(IERC721(_generalAddress).ownerOf(_lastId) == _owner,
                "The owner is not correct"
        );
        uint256 newTokenId = Monster(_monsterAddress).fusionRegeneration(_owner);
        GeneralHash(_generalAddress).fusionRegeneration(_firstId);
        GeneralHash(_generalAddress).fusionRegeneration(_lastId);
        emit fusionGeneralHashNFT(_owner, _firstId, _lastId, newTokenId);
    }

    /*
     * Create monster from fusion genesis + general hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _genesisAddress: address of genesis contract
     * @param _generalAddress: address of general contract
     * @param _genersisId: genesis tokenId fusion 
     * @param _generalId: general tokenId fusion 
     */
    function fusionMultipleHash(address _monsterAddress,
                                address _genesisAddress,
                                address _generalAddress,
                                address _owner,
                                uint256 _genesisId,
                                uint256 _generalId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(IERC721(_genesisAddress).ownerOf(_genesisId) == _owner,
                "The owner is not correct"
        );
        require(IERC721(_generalAddress).ownerOf(_generalId) == _owner,
                "The owner is not correct"
        );
        uint256 newTokenId = Monster(_monsterAddress).fusionRegeneration(_owner);
        GeneralHash(_generalAddress).fusionRegeneration(_generalId);
        emit fusionMultipleHashNFT(_owner, _genesisId, _generalId, newTokenId);
    }

    /*
     * Create monster from genersis hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _genesisAddress: address of genesis contract
     * @param _genesisId: genesis tokenId fusion 
     */
    function createMonsterFromGenesisHash(
                                        address _monsterAddress,
                                        address _genesisAddress,
                                        address _owner,
                                        uint256 _genesisId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(IERC721(_genesisAddress).ownerOf(_genesisId) == _owner,
                "The owner is not correct"
        );
        uint256 tokenId = Monster(_monsterAddress).createNFT(_owner);
        emit createMonsterFromGenesis(_owner, _genesisId, tokenId);
    }
 /*
     * Create monster from general hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _generalAddress: address of genesis contract
     * @param _generalId: genesis tokenId fusion 
     */
    function createMonsterFromGeneralHash(
                                        address _monsterAddress,
                                        address _generalAddress,
                                        address _owner,
                                        uint256 _generalId
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(IERC721(_generalAddress).ownerOf(_generalId) == _owner,
                "The owner is not correct"
        );
        uint256 tokenId = Monster(_monsterAddress).createNFT(_owner);
        GeneralHash(_generalAddress).fusionRegeneration(_generalId);
        emit createMonsterFromGeneral(_owner, _generalId, tokenId);
    }
/*
     * Create Accessories
     * @param _owner: address of owner
     * @param _accessoriesAddress: address of Accessories contract
     * @param _materialAddress: address of material contract
     * @param _generalId: id of material
     */
    function createAccessories(
                                address _accessoriesAddress,
                                address _owner
                                // address _materialAddress ,
                                // uint256 _materialId,
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        Accessories(_accessoriesAddress).mintAccessories(_owner);
    }

}   
