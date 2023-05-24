// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMonster {
    //fusion monster
    function mint(address _address) external returns (uint256);

    //burn monster
    function burn(uint256 _tokenId) external;

    //get lifeSpan monster
    function getStatusMonster(uint256 tokenId) external view returns (bool);

    // check monster is free?
    function isFreeMonster(uint256 tokenId) external view returns (bool);
}

interface IMonsterMemory {
    // mint monster memory
    function mint(address _address) external returns (uint256);
}

interface ICoach {
    // mint coach
    function mint(address _address, bool _status) external returns (uint256);
}

interface IMonsterCrystal {
    // mint crystal
    function mint(address _address, bool _status) external returns (uint256);
}

interface IGenesisHash {
    // my genesishash
    function burn(uint256 _tokenId) external;
}

interface IGeneralHash {
    // mint generalhash
    function burn(uint256 _tokenId) external;
}

interface IAccessories {
    // mint accessories
    function mint(address _address) external returns (uint256);
}

interface IMonsterItem {
    // burn item from tokenid
    function burn(address _from, uint256 _id, uint256 _amount) external;
}

contract MonsterManagerment is Ownable, AccessControl, Pausable {
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    IMonster monsterContract;
    IMonsterMemory monsterMemory;
    ICoach coach;
    IMonsterCrystal crystal;
    IGenesisHash genesis;
    IGeneralHash general;
    IAccessories accessories;
    IMonsterItem item;

    constructor(
        IMonster _monster,
        IMonsterMemory _monsterMemory,
        ICoach _coach,
        IMonsterCrystal _crystal,
        IGenesisHash _genesis,
        IGeneralHash _general,
        IAccessories _accessories,
        IMonsterItem _item
    ) {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        monsterContract = _monster;
        monsterMemory = _monsterMemory;
        coach = _coach;
        crystal = _crystal;
        genesis = _genesis;
        general = _general;
        accessories = _accessories;
        item = _item;
    }

    // count regeration General limit
    mapping(uint256 => uint256) private _countGeneral;

    // regeration General limit
    uint256 private generalLimit;
    // Fusion 2 monster, monster lifeSpan == false => mint 2 monster memory
    event fusionNFTMonsterMemorys(
        address _owner,
        uint256 _newMonster,
        uint256 _firstTokenId,
        uint256 _lastTokenId,
        uint256 _firstMemory,
        uint256 _lastMemory
    );
    // Fusion 2 monster, monster lifeSpan == true => not mint monster memory
    event fusionNFTMonsterNotMemory(
        address _owner,
        uint256 _newMonster,
        uint256 _firstTokenId,
        uint256 _lastTokenId
    );
    // Fusion 2 monster,first monster lifeSpan == true && last monster lifespan == false => mint 1 memory
    event fusionNFTMonsterMemory(
        address _owner,
        uint256 _newMonster,
        uint256 _firstTokenId,
        uint256 _lastTokenId,
        uint256 _memoryId
    );
    // Create coach from monster
    event createCoachByMonster(
        address _owner,
        uint256 _newCoach,
        uint256 _tokenBurn,
        uint256 _newMonsterMemory
    );
    // Create Crystal from monster
    event createCrystalByMonster(
        address _owner,
        uint256 _newCrystal,
        uint256 _tokenBurn,
        uint256 _newMonsterMemory
    );
    // Fusion 2 genesishash => monster
    event fusionGenesisHashNFT(
        address _owner,
        uint256 _fistId,
        uint256 _lastId,
        uint256 _newTokenId
    );
    /*
     * fusion 2 general hash => monster
     * @param _owner: address of owner
     * @param _fistId: first tokenId of generalHash
     * @param _lastId: last tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionGeneralHashNFT(
        address _owner,
        uint256 _fistId,
        uint256 _lastId,
        uint256 _newTokenId
    );
    /*
     * fusion genesishash + generalhash
     * @param _owner: address of owner
     * @param _genesisId: tokenId of genesisHash
     * @param _generalId: tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionMultipleHashNFT(
        address _owner,
        uint256 _genesisId,
        uint256 _generalId,
        uint256 _newTokenId
    );
    // Create monster from genesis hash
    event createMonsterFromGenesis(
        address _owner,
        uint256 _genesisId,
        uint256 _newTokenId
    );
    // Create monster of general hash
    event createMonsterFromGeneral(
        address _owner,
        uint256 _generalId,
        uint256 _newTokenId
    );
    /*
     * create Accessories From material
     * @param _owner: address of owner
     * @param _materialId: id of material item
     * @param _newTokenId: new tokenId of Accessories
     */
    event createAccessoriesNFT(
        address _owner,
        uint256 _materialId,
        uint256 _newTokenId
    );

    // Create monster from NFTs
    event createMonsterFromNFTs(
        address _nftAddress,
        address _owner,
        uint256 _nftTokenId,
        uint256 _newTokenId
    );

    // Set mint limit
    function setMintLimit(uint256 _number) public onlyOwner {
        generalLimit = _number;
    }

    /*
     * fusion a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */
    function fusionMonsterNFT(
        address _owner,
        uint256 _firstTokenId,
        uint256 _lastTokenId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(monsterContract)).ownerOf(_firstTokenId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(monsterContract)).ownerOf(_lastTokenId) == _owner,
            "The owner is not correct"
        );
        uint256 newTokenId = monsterContract.mint(_owner);
        bool lifeSpanFistMonster = monsterContract.getStatusMonster(
            _firstTokenId
        );
        bool lifeSpanLastMonster = monsterContract.getStatusMonster(
            _lastTokenId
        );
        monsterContract.burn(_firstTokenId);
        monsterContract.burn(_lastTokenId);
        if (!lifeSpanFistMonster && !lifeSpanLastMonster) {
            // mint monster memory
            uint256 firstMemory = monsterMemory.mint(_owner);
            uint256 lastMemory = monsterMemory.mint(_owner);
            emit fusionNFTMonsterMemorys(
                _owner,
                newTokenId,
                _firstTokenId,
                _lastTokenId,
                firstMemory,
                lastMemory
            );
        } else if (
            (!lifeSpanFistMonster && lifeSpanLastMonster) ||
            (lifeSpanFistMonster && !lifeSpanLastMonster)
        ) {
            // mint monster memory
            uint256 memoryId = monsterMemory.mint(_owner);
            emit fusionNFTMonsterMemory(
                _owner,
                newTokenId,
                _firstTokenId,
                _lastTokenId,
                memoryId
            );
        } else {
            emit fusionNFTMonsterNotMemory(
                _owner,
                newTokenId,
                _firstTokenId,
                _lastTokenId
            );
        }
    }

    /*
     * Create coach from Monster
     * @param _owner: first tokenId fusion => burn
     * @param _idBurn: last tokenId fusion => burn
     */
    function createCoachNFT(
        address _owner,
        uint256 _idBurn
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(monsterContract)).ownerOf(_idBurn) == _owner,
            "The owner is not correct"
        );
        bool isStatusMonster = monsterContract.getStatusMonster(_idBurn);
        require(
            !isStatusMonster,
            "MonsterManagerment: createCoachNFT: The monster is alive"
        );
        bool isFreeMonster = monsterContract.isFreeMonster(_idBurn);
        monsterContract.burn(_idBurn);
        uint256 tokenId;
        if (isFreeMonster) {
            tokenId = coach.mint(_owner, true);
        } else {
            tokenId = coach.mint(_owner, false);
        }
        uint256 newMonsterMemory = monsterMemory.mint(_owner);
        emit createCoachByMonster(_owner, tokenId, _idBurn, newMonsterMemory);
    }

    /*
     * Create crystal from Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */
    function createMonsterCrystalNFT(
        address _owner,
        uint256 _idBurn
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
         require(
            IERC721(address(monsterContract)).ownerOf(_idBurn) == _owner,
            "The owner is not correct"
        );
        bool isStatusMonster = monsterContract.getStatusMonster(_idBurn);
        require(
            !isStatusMonster,
            "MonsterManagerment: createCoachNFT: The monster is alive"
        );
        bool isFreeMonster = monsterContract.isFreeMonster(_idBurn);
        monsterContract.burn(_idBurn);
        uint256 tokenId;
        if (isFreeMonster) {
            tokenId = crystal.mint(_owner, true);
        } else {
            tokenId = crystal.mint(_owner, false);
        }
        uint256 newMonsterMemory = monsterMemory.mint(_owner);
        emit createCrystalByMonster(_owner, tokenId, _idBurn, newMonsterMemory);
    }

    /*
     * Create monster from fusion genersis hash
     * @param _owner: address of owner
     * @param _firstId: first tokenId fusion
     * @param _lastId: last tokenId fusion
     */
    function fusionGenesisHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(genesis)).ownerOf(_firstId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(genesis)).ownerOf(_lastId) == _owner,
            "The owner is not correct"
        );
        uint256 newTokenId = monsterContract.mint(_owner);
        emit fusionGenesisHashNFT(_owner, _firstId, _lastId, newTokenId);
    }

    /*
     * Create monster from fusion general hash
     * @param _owner: address of owner
     * @param _firstId: first tokenId fusion
     * @param _lastId: last tokenId fusion
     */
    function fusionGeneralHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(general)).ownerOf(_firstId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(general)).ownerOf(_lastId) == _owner,
            "The owner is not correct"
        );
        uint256 newTokenId = monsterContract.mint(_owner);
        _countGeneral[_firstId]++;
        _countGeneral[_lastId]++;
        if (_countGeneral[_firstId] == generalLimit) {
            general.burn(_firstId);
        }
        if (_countGeneral[_lastId] == generalLimit) {
            general.burn(_lastId);
        }
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
    function fusionMultipleHash(
        address _owner,
        uint256 _genesisId,
        uint256 _generalId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(genesis)).ownerOf(_genesisId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(general)).ownerOf(_generalId) == _owner,
            "The owner is not correct"
        );
        uint256 newTokenId = monsterContract.mint(_owner);
        if (_countGeneral[_generalId] == generalLimit) {
            general.burn(_generalId);
        }
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
        address _owner,
        uint256 _genesisId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(genesis)).ownerOf(_genesisId) == _owner,
            "The owner is not correct"
        );
        uint256 tokenId = monsterContract.mint(_owner);
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
        address _owner,
        uint256 _generalId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(address(general)).ownerOf(_generalId) == _owner,
            "The owner is not correct"
        );
        uint256 tokenId = monsterContract.mint(_owner);
        if (_countGeneral[_generalId] == generalLimit) {
            general.burn(_generalId);
        }
        emit createMonsterFromGeneral(_owner, _generalId, tokenId);
    }

    /*
     * Create monster from general hash
     * @param _owner: address of owner
     * @param _monsterAddress: address of monster contract
     * @param _generalAddress: address of genesis contract
     * @param _generalId: genesis tokenId fusion
     */
    function createMonsterFromNFT(
        address _nftAddress,
        address _owner,
        uint256 _nftTokenId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            IERC721(_nftAddress).ownerOf(_nftTokenId) == _owner,
            "The owner is not correct"
        );
        uint256 tokenId = monsterContract.mint(_owner);
        emit createMonsterFromNFTs(_nftAddress, _owner, _nftTokenId, tokenId);
    }

    /*
     * Create Accessories
     * @param _owner: address of owner
     * @param _accessoriesAddress: address of Accessories contract
     * @param _materialAddress: address of material contract
     * @param _generalId: id of material
     */
    function createAccessories(
        address _owner,
        uint256 _materialId,
        uint256 _number
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 tokenId = accessories.mint(_owner);
        item.burn(_owner, _materialId, _number);
        emit createAccessoriesNFT(_owner, _materialId, tokenId);
    }
}
