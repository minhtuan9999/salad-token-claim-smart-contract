// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IGeneralHash {
    function burn(uint256 _tokenId) external;
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external;
    function _numberOfRegenerations(uint256 season, uint256 tokenId) external view returns (uint256);
}
interface IGenesisHash is IGeneralHash {}
interface IHashChip {
    function burn(address _from, uint256 _id, uint256 _amount) external;
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external;
    function _numberOfRegenerations(uint256 season, uint256 tokenId) external view returns (uint256);
}
interface IToken {
    function burnToken(address account, uint256 amount) external;
}
interface IMonsterMemory {
    function mint(address _address, uint256 _monsterId) external;
}
interface IRegenerationItem {
    function burn(address _from, uint256 _id, uint256 _amount) external;
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external;
    function isMintMonster(uint256 _itemId) external view returns (bool);
}
interface IFusionItem is IRegenerationItem {}
interface IMonsterContract {
    function mintMonster(address _address, uint8 _type) external returns (uint256);
    function getStatusMonster(uint256 _tokenId) external view returns (bool);
    function burn(uint256 _tokenId) external;
}

contract RegenFusionMonster is Ownable,
    AccessControl,
    Pausable,
    ReentrancyGuard
    {
    IToken public tokenBaseContract;
    IGenesisHash public genesisHashContract;
    IGeneralHash public generalHashContract;
    IHashChip public hashChipNFTContract;
    IMonsterMemory public monsterMemory;
    IRegenerationItem public regenerationItem;
    IFusionItem public fusionItem;
    IMonsterContract public monsterContract;

    bytes32 public constant MANAGEMENT_ROLE  = keccak256("MANAGEMENT_ROLE");
    string _baseURIextended;

    // Season
    uint256 public season;
    // Validator
    address validator;
    // Address receive fee
    address receiveFee;
    // Decimal  
    uint256 public DECIMAL = 10^18;
    // Status signature
    mapping(bytes => bool) public _isSigned;
    
    uint8 NFT = 0;
    uint8 COLLABORATION_NFT = 1;
    uint8 FREE = 2;
    uint8 GENESIS_HASH = 3;
    uint8 GENERAL_HASH = 4;
    uint8 HASH_CHIP_NFT = 5;
    uint8 REGENERATION_ITEM = 6;
    uint8 FUSION_GENESIS_HASH = 7;
    uint8 FUSION_MULTIPLE_HASH = 8;
    uint8 FUSION_GENERAL_HASH = 9;
    uint8 FUSION_MONSTER = 10;

    // Costs and Limits
    uint256[] public costOfGenesis = [8, 9, 10, 11, 12];
    uint256[] public costOfGeneral = [8, 10, 12];
    uint256[] public costOfNfts = [8, 10, 12];
    uint256[] public costOfExternal = [8, 10, 12];
    uint256[] public costOfHashChip = [8, 10, 12];

    uint256[6] public limits = [3, 3, 0, 5, 3, 3];

    uint256 public nftRepair = 10;

    event FusionMonsterNFT(
        address owner,
        uint256 newMonster,
        uint256 firstTokenId,
        uint256 lastTokenId,
        uint8 mainSeed,
        uint8 subSeed
    );

    event FusionGenesisHash(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId,
        uint8 mainSeed,
        uint8 subSeed
    );

    event FusionGeneralHash(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId,
        uint8 mainSeed,
        uint8 subSeed
    );

    event FusionMultipleHash(
        address owner,
        uint256 genesisId,
        uint256 generalId,
        uint256 newTokenId,
        uint8 mainSeed,
        uint8 subSeed
    );

    event RefreshTimesRegeneration(uint8 _type, uint256 tokenId);
    
    event RegenerationMonster(address owner, uint256 tokenId, uint8 _type, uint8 mainSeed, uint8 subSeed);

    // Check status mint nft free of address
    mapping(address => bool) public _realdyFreeNFT;
    //  =>( TypeMint => chainId => (contractAddress => (tokenId => number Of Regenerations)))
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => uint256))))
        public _timesRegenExternal;

    // Set contract addresses
    function initContractAddress(
        IToken _tokenBase,
        IGeneralHash _generalHash,
        IGenesisHash _genesisHash,
        IHashChip _hashChip,
        IMonsterMemory _monsterMemory,
        IRegenerationItem _regenerationItem,
        IFusionItem _fusionItem,
        IMonsterContract _monsterContract,
        address receiveFreeAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        tokenBaseContract = _tokenBase;
        generalHashContract = _generalHash;
        genesisHashContract = _genesisHash;
        hashChipNFTContract = _hashChip;
        monsterMemory = _monsterMemory;
        regenerationItem = _regenerationItem;
        fusionItem = _fusionItem;
        monsterContract = _monsterContract;
        receiveFee = receiveFreeAddress;
    }

    constructor(){
        _setRoleAdmin(MANAGEMENT_ROLE , MANAGEMENT_ROLE );
        _setupRole(MANAGEMENT_ROLE , _msgSender());
    }

    function setValidator(
        address _address
    ) external whenNotPaused onlyOwner {
        validator = _address;
    }

    function setNewSeason() external onlyRole(MANAGEMENT_ROLE) {
        season++;
    }

    function setNftRepair(uint256 _cost) external onlyRole(MANAGEMENT_ROLE) {
        nftRepair = _cost;
    }

    function setCostOfType(uint8 _type, uint256[] memory cost) external onlyRole(MANAGEMENT_ROLE) {
        require(limits[_type] > 0, "Unsupported type");
        if (_type == GENERAL_HASH) costOfGeneral = cost;
        else if (_type == GENESIS_HASH) costOfGenesis = cost;
        else if (_type == NFT) costOfNfts = cost;
        else if (_type == COLLABORATION_NFT) costOfExternal = cost;
        else if (_type == HASH_CHIP_NFT) costOfHashChip = cost;
    }

    function setLimitOfType(
        uint8 _type,
        uint256 limit
    ) external onlyRole(MANAGEMENT_ROLE) {
        limits[_type] = limit;
    }

    function _fromGeneralHash(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = generalHashContract._numberOfRegenerations(season, _tokenId);
        require(times < limits[GENERAL_HASH],"Times limit");
        require(IERC721(address(generalHashContract)).ownerOf(_tokenId) == msg.sender,"Wrong owner");
        generalHashContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        if (times + 1 == limits[GENERAL_HASH]) {
            generalHashContract.burn(_tokenId);
        }
        return monsterContract.mintMonster(msg.sender, GENERAL_HASH);
    }

    function _fromGenesisHash(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = genesisHashContract._numberOfRegenerations(season, _tokenId);
        require(times < limits[GENESIS_HASH],"Times limit");
        require(IERC721(address(genesisHashContract)).ownerOf(_tokenId) == msg.sender,"Wrong owner");
        genesisHashContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        return monsterContract.mintMonster(msg.sender, GENESIS_HASH);
    }

    function _fromExternalNFT(
        uint8 _type,
        uint256 _chainId,
        address _address,
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = _timesRegenExternal[season][_chainId][_address][_tokenId];
        if(isERC721(_address)){
            require(IERC721(_address).ownerOf(_tokenId) == msg.sender,"Wrong owner");
        }else if(isERC1155(_address)){
            require(IERC1155(_address).balanceOf(_address, _tokenId) > 0,"Balance not enough");
        }
        require(times < limits[_type],"Times limit");
        _timesRegenExternal[season][_chainId][_address][_tokenId]++;
        return monsterContract.mintMonster(msg.sender, _type);
    }

    function _fromHashChipNFT(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = hashChipNFTContract._numberOfRegenerations(season, _tokenId);
        require(times < limits[HASH_CHIP_NFT],"Times limit");
        require(IERC721(address(hashChipNFTContract)).ownerOf(_tokenId) == msg.sender,"Wrong owner");
        hashChipNFTContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        return monsterContract.mintMonster(msg.sender, HASH_CHIP_NFT);
    }

    /*
     * Create a Monster by type
     * @param _type: address of owner
     * @param _tokenId: first tokenId fusion
     * @param _isOAS: last tokenId fusion
     * @param _cost: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _deadline: number of fusion item
     */
    function mintMonster(
        uint8 _type,
        address _addressContract,
        uint256 _chainId,
        address _account,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig,
        uint8 _mainSeed,
        uint8 _subSeed
    ) external payable nonReentrant whenNotPaused {
        if (_isOAS) {
            require(_deadline > block.timestamp,"Deadline exceeded");
            require(!_isSigned[_sig],"Signature used");
            address signer = recoverOAS(
                _type,
                _account,
                _cost,
                _tokenId,
                block.chainid,
                _deadline,
                _sig
            );
            require(signer == validator, "Validator fail signature");
            bool sent = payable(receiveFee).send(_cost);
            require(
                sent,
                "TreasuryContract::reward: Failed to claim OAS"
            );
        } else {
            uint256 cost = getFeeOfTokenId(_type, _chainId, _addressContract, _tokenId);
            tokenBaseContract.burnToken(msg.sender, cost*DECIMAL );
        }

        uint256 tokenId;
        if (_type == GENERAL_HASH) {
            tokenId = _fromGeneralHash(_tokenId);
        } else if (_type == GENESIS_HASH) {
            tokenId = _fromGenesisHash(_tokenId);
        } else if (_type == NFT || _type == COLLABORATION_NFT) {
            tokenId = _fromExternalNFT( _type, _chainId, _addressContract, _tokenId);
        } else if (_type == HASH_CHIP_NFT) {
            tokenId = _fromHashChipNFT(_tokenId);
        } else {
            revert("Unsupported type");
        }
        emit RegenerationMonster(msg.sender, tokenId, _type, _mainSeed, _subSeed);
    }

    /*
     * Create a Monster by type Free
     */
    function mintMonsterFromRegeneration(uint256 _itemId, uint8 _mainSeed, uint8 _subSeed) external nonReentrant whenNotPaused {
        require(regenerationItem.isMintMonster(_itemId), "Wrong id");
        regenerationItem.burn(msg.sender, _itemId, 1);
        emit RegenerationMonster(msg.sender,monsterContract.mintMonster(msg.sender, REGENERATION_ITEM), REGENERATION_ITEM, _mainSeed, _subSeed);
    }
    
    /*
     * fusion a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion
     * @param _lastTokenId: last tokenId fusion
     * @param _itemId: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _amount: number of fusion item
     */
    function fusionMonsterNFT(
        address _owner,
        uint256 _firstTokenId,
        uint256 _lastTokenId,
        uint256[] memory _listItem,
        uint256[] memory _amount,
        uint8 _mainSeed,
        uint8 _subSeed
    ) external nonReentrant whenNotPaused {
        require(_listItem.length == _amount.length, "Input error");
        if(_amount[0] != 0) {
            fusionItem.burnMultipleItem(_owner, _listItem, _amount);
        }
        require(IERC721(address(monsterContract)).ownerOf(_firstTokenId) == _owner, "The owner is not correct");
        require(IERC721(address(monsterContract)).ownerOf(_lastTokenId) == _owner, "The owner is not correct");
        bool lifeSpanFistMonster = monsterContract.getStatusMonster(_firstTokenId);
        bool lifeSpanLastMonster = monsterContract.getStatusMonster(_lastTokenId);
        if (!lifeSpanFistMonster) {
            monsterMemory.mint(_owner, _firstTokenId);
        }
        if (!lifeSpanLastMonster) {
            monsterMemory.mint(_owner, _lastTokenId);
        }
        monsterContract.burn(_firstTokenId);
        monsterContract.burn(_lastTokenId);
        emit FusionMonsterNFT(
            _owner,
            monsterContract.mintMonster(_owner, FUSION_MONSTER),
            _firstTokenId,
            _lastTokenId,
            _mainSeed,
            _subSeed
        );
    }

    /*
     * Create monster from fusion genersis hash
     * @param _owner: address of owner
     * @param _firstId: first tokenId fusion
     * @param _lastId: last tokenId fusion
     * @param _itemId: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _amount: number of fusion item
     */
    function fusionGenesisHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId,
        uint256[] memory _listItem,
        uint256[] memory _amount,
        uint8 _mainSeed,
        uint8 _subSeed
    ) external nonReentrant whenNotPaused {
        require(_listItem.length == _amount.length, "Input error");
        if(_amount[0] != 0) {
            fusionItem.burnMultipleItem(_owner, _listItem, _amount);
        }
        uint256 timesRegeneration1 = genesisHashContract._numberOfRegenerations(season, _firstId);
        uint256 timesRegeneration2 = genesisHashContract._numberOfRegenerations(season, _lastId);
        require(
            IERC721(address(genesisHashContract)).ownerOf(_firstId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(genesisHashContract)).ownerOf(_lastId) == _owner,
            "The owner is not correct"
        );
        require(
            timesRegeneration1 < limits[GENESIS_HASH] &&
                timesRegeneration2 < limits[GENESIS_HASH],
            "Exceed the allowed number of times"
        );

        genesisHashContract.setTimesOfRegeneration(season, _firstId, timesRegeneration1 + 1);
        genesisHashContract.setTimesOfRegeneration(season, _lastId, timesRegeneration2 + 1);
        emit FusionGenesisHash(_owner, _firstId, _lastId, monsterContract.mintMonster(_owner, FUSION_GENESIS_HASH), _mainSeed, _subSeed);
    }
     /*
     * Create monster from fusion general hash
     * @param _owner: address of owner
     * @param _firstId: first tokenId fusion
     * @param _lastId: last tokenId fusion
     * @param _itemId: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _amount: number of fusion item
     */
    function fusionGeneralHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId,
        uint256[] memory _listItem,
        uint256[] memory _amount,
        uint8 _mainSeed,
        uint8 _subSeed
    ) external nonReentrant whenNotPaused {
        require(_listItem.length == _amount.length, "Input error");
        if(_amount[0] != 0) {
            fusionItem.burnMultipleItem(_owner, _listItem, _amount);
        }
        uint256 timesRegeneration1 = generalHashContract._numberOfRegenerations(season, _firstId);
        uint256 timesRegeneration2 = generalHashContract._numberOfRegenerations(season, _lastId);
        require(
            IERC721(address(generalHashContract)).ownerOf(_firstId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_lastId) == _owner,
            "The owner is not correct"
        );
        require(
            timesRegeneration1 < limits[GENERAL_HASH] &&
                timesRegeneration2 < limits[GENERAL_HASH],
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(season, _firstId, timesRegeneration1 + 1);
        genesisHashContract.setTimesOfRegeneration(season, _lastId, timesRegeneration2 + 1);

        if (timesRegeneration1 + 1 == limits[GENERAL_HASH]) {
            generalHashContract.burn(_firstId);
        }
        if (timesRegeneration2 + 1 == limits[GENERAL_HASH]) {
            generalHashContract.burn(_lastId);
        }
        emit FusionGeneralHash(_owner, _firstId, _lastId, monsterContract.mintMonster(_owner, FUSION_GENERAL_HASH), _mainSeed, _subSeed);
    }

    /*
     * Create monster from fusion genesis + general hash
     * @param _owner: address of owner
     * @param _genersisId: genesis tokenId fusion
     * @param _generalId: general tokenId fusion
     * @param _itemId: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _amount: number of fusion item
     */
    function fusionMultipleHash(
        address _owner,
        uint256 _genesisId,
        uint256 _generalId,
        uint256[] memory _listItem,
        uint256[] memory _amount,
        uint8 _mainSeed,
        uint8 _subSeed
    ) external nonReentrant whenNotPaused {
        require(_listItem.length == _amount.length, "Input error");
        if(_amount[0] != 0) {
            fusionItem.burnMultipleItem(_owner, _listItem, _amount);
        }
        uint256 timesGenesis = genesisHashContract._numberOfRegenerations(season, _genesisId);
        uint256 timesGeneral = generalHashContract._numberOfRegenerations(season, _generalId);
        require(
            IERC721(address(genesisHashContract)).ownerOf(_genesisId) == _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_generalId) == _owner,
            "The owner is not correct"
        );
        require(
            timesGenesis < limits[GENESIS_HASH] && timesGeneral < limits[GENERAL_HASH],
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(season, _genesisId, timesGenesis + 1);
        generalHashContract.setTimesOfRegeneration(season, _generalId, timesGeneral + 1);
        if (timesGeneral + 1 == limits[GENERAL_HASH]) {
            generalHashContract.burn(_generalId);
        }
        emit FusionMultipleHash(_owner, _genesisId, _generalId, monsterContract.mintMonster(_owner, FUSION_MULTIPLE_HASH), _mainSeed, _subSeed);
    }

    function _refreshTimesOfRegeneration(
        uint8 _type,
        uint256 _chainId,
        address _address,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) private {
        if (_isOAS) {
            bool sent = payable(receiveFee).send(_cost);
            require(
                sent,
                "TreasuryContract::reward: Failed to claim OAS"
            );
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        if (_type == NFT ) {
            require(
                _timesRegenExternal[season][_chainId][_address][_tokenId] == limits[NFT],
                "Item being used"
            );
            _timesRegenExternal[season][_chainId][_address][_tokenId] = 0;
        } else if (_type == COLLABORATION_NFT ) {
            require(
                _timesRegenExternal[season][_chainId][_address][_tokenId] == limits[COLLABORATION_NFT],
                "Item being used"
            );
            _timesRegenExternal[season][_chainId][_address][_tokenId] = 0;
        }else if (_type == GENESIS_HASH) {
            require(
                genesisHashContract._numberOfRegenerations(season, _tokenId) == limits[GENESIS_HASH],
                "Item being used"
            );
            genesisHashContract.setTimesOfRegeneration(season, _tokenId, 0);
        } else if (_type == HASH_CHIP_NFT) {
            require(
                hashChipNFTContract._numberOfRegenerations(season, _tokenId) == limits[HASH_CHIP_NFT],
                "Item being used"
            );
           hashChipNFTContract.setTimesOfRegeneration(season, _tokenId, 0);
        } else {
            revert(
                "Unsupported type"
            );
        }
    }

     /*
     * get Fee mint Monster by TyMint & tokenId
     * @param _type: TypeMint
     * @param _tokenId: tokenId
     */
    function getFeeOfTokenId(
        uint8 _type,
        uint256 _chainId,
        address _address,
        uint256 _tokenId
    ) public view whenNotPaused returns (uint256 fee) {
        if (_type == NFT) {
            fee = costOfNfts[_timesRegenExternal[season][_chainId][_address][_tokenId]];
        } else if (_type == COLLABORATION_NFT) {
            fee = costOfExternal[_timesRegenExternal[season][_chainId][_address][_tokenId]];
        } else if (_type == GENESIS_HASH) {
            fee = costOfGenesis[genesisHashContract._numberOfRegenerations(season, _tokenId)];
        } else if (_type == GENERAL_HASH) {
            fee = costOfGeneral[generalHashContract._numberOfRegenerations(season, _tokenId)];
        } else if (_type == HASH_CHIP_NFT) {
            fee = costOfHashChip[hashChipNFTContract._numberOfRegenerations(season, _tokenId)];
        } else {
            revert("Unsupported type");
        }
    }

    /*
     * Refresh Times Of Regeneration
     * @param _type: address of owner
     * @param _tokenId: first tokenId fusion
     * @param _isOAS: last tokenId fusion
     * @param _cost: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _deadline: number of fusion item
     */
    function refreshTimesOfRegeneration(
        uint8 _type,
        uint256 _chainId,
        address _addressContract,
        address _account,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig
    ) external payable nonReentrant whenNotPaused {
        require(
            _deadline > block.timestamp,
            "Deadline exceeded"
        );
        require(
            !_isSigned[_sig],
            "Signature used"
        );
        address signer = recoverOAS(
            _type,
            _account,
            _cost,
            _tokenId,
            block.chainid,
            _deadline,
            _sig
        );
        require(
            signer == validator,
            "Validator fail signature"
        );
        _refreshTimesOfRegeneration(_type, _chainId, _addressContract, _tokenId, _isOAS, _cost);
    }

    function isERC721(address contractAddress) internal view returns (bool) {
        try
            IERC721(contractAddress).supportsInterface(
                type(IERC721).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    function isERC1155(address contractAddress) internal view returns (bool) {
        try
            IERC1155(contractAddress).supportsInterface(
                type(IERC1155).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    /*
     * encode data 
     * @param _type: type mint Monster
     * @param cost: fee mint NFT
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     */
    function encodeOAS(
        uint8 _type,
        address account,
        uint256 cost,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_type, account, cost, tokenId, chainId, deadline));
    }

    /*
     * recover data 
     * @param _type: type mint Monster
     * @param cost: fee mint NFT
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     * @param signature: signature encode data
     */
    function recoverOAS(
        uint8 _type,
        address _account,
        uint256 cost,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline,
        bytes calldata signature 
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeOAS(_type, _account, cost, tokenId, chainId, deadline)
                ),
                signature 
            );
    }
}
