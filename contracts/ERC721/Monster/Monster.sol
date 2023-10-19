// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./MonsterBase.sol";

interface IGeneralHash {
    function burn(uint256 _tokenId) external;
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external;
    function _numberOfRegenerations(uint256 season, uint256 tokenId) external view returns(uint256);
}

interface IGenesisHash {
    function burn(uint256 _tokenId) external;
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external;
    function _numberOfRegenerations(uint256 season, uint256 tokenId) external view returns(uint256);
}

interface IHashChip {
    function burn(address _from, uint256 _id, uint256 _amount) external;
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external;
    function _numberOfRegenerations(uint256 season, uint256 tokenId) external view returns(uint256);
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

contract Monster is MonsterBase {
    IToken public tokenBaseContract;
    IGenesisHash public genesisHashContract;
    IGeneralHash public generalHashContract;
    IHashChip public hashChipNFTContract;
    IMonsterMemory public monsterMemory;
    IRegenerationItem public regenerationItem;
    IFusionItem public fusionItem;
    ITreasuryContract public treasuryContract;
    
    // Season
    uint256 public season;
        // Validator
    address private validator;
    // Decimal  
    uint256 public decimal = 10^18;
    // Status signature
    mapping(bytes => bool) public _isSigned;
    uint256[] public costOfGenesis = [8, 9, 10, 11, 12];
    uint256[] public costOfGeneral = [8, 10, 12];
    uint256[] public costOfExternal = [8, 10, 12];
    uint256[] public costOfHashChip = [8, 10, 12];

    uint256 public limitGenesis = 5;
    uint256 public limitGeneral = 3;
    uint256 public limitExternal = 3;
    uint256 public limitHashChip = 3;

    uint256 public nftRepair = 10;

    // Set contract token OAS
    function setTokenBaseContract(
        IToken _tokenBase
    ) external onlyRole(MANAGEMENT_ROLE) {
        tokenBaseContract = _tokenBase;
    }

    // Set contract General Hash
    function setGeneralHashContract(
        IGeneralHash generalHash
    ) external onlyRole(MANAGEMENT_ROLE) {
        generalHashContract = generalHash;
    }

    // Set contract Genesis Hash
    function setGenesisHashContract(
        IGenesisHash genesisHash
    ) external onlyRole(MANAGEMENT_ROLE) {
        genesisHashContract = genesisHash;
    }

    // Set contract Hash Chip NFT
    function setHashChipContract(
        IHashChip hashChip
    ) external onlyRole(MANAGEMENT_ROLE) {
        hashChipNFTContract = hashChip;
    }

    // Set contract Monster memory
    function setMonsterMemoryContract(
        IMonsterMemory _monsterMemory
    ) external onlyRole(MANAGEMENT_ROLE) {
        monsterMemory = _monsterMemory;
    }

    // Set contract Monster Item
    function setRegenerationContract(
        IRegenerationItem _regenerationItem
    ) external onlyRole(MANAGEMENT_ROLE) {
        regenerationItem = _regenerationItem;
    }

    // Set contract Fusion Item
    function setFusionContract(
        IFusionItem _fusionItem
    ) external onlyRole(MANAGEMENT_ROLE) {
        fusionItem = _fusionItem;
    }

    // Set Treasury contract
    function setTreasuryContract(
        ITreasuryContract _treasuryContract
    ) external onlyRole(MANAGEMENT_ROLE) {
        treasuryContract = _treasuryContract;
    }

    /*
     * fusion 2 Monster => monster
     * @param owner: address of owner
     * @param newMonster: new tokenId of Monster
     * @param firstTokenId: tokenId of monster fusion
     * @param lastTokenId: tokenId of monster fusion
     */
    event fusionMultipleMonster(
        address owner,
        uint256 newMonster,
        uint256 firstTokenId,
        uint256 lastTokenId
    );

    /*
     * fusion 2 genesis hash => monster
     * @param owner: address of owner
     * @param fistId: first tokenId of genesisHash
     * @param lastId: last tokenId of genesisHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionGenesisHashNFT(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId
    );
    /*
     * fusion 2 general hash => monster
     * @param owner: address of owner
     * @param fistId: first tokenId of generalHash
     * @param lastId: last tokenId of generalHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionGeneralHashNFT(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId
    );
    /*
     * fusion genesishash + generalhash
     * @param owner: address of owner
     * @param genesisId: tokenId of genesisHash
     * @param generalId: tokenId of generalHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionMultipleHashNFT(
        address owner,
        uint256 genesisId,
        uint256 generalId,
        uint256 newTokenId
    );
    /*
     * refresh Times Of Regeneration
     * @param _type: type mint Monster
     * @param tokenId: tokenId of nft
     */
    event refreshTimesRegeneration(TypeMint _type, uint256 tokenId);
    // Check status mint nft free of address
    mapping(address => bool) public _realdyFreeNFT;
    //  =>( TypeMint => chainId => (contractAddress => (tokenId => number Of Regenerations)))
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => uint256))))
        public _timesRegenExternal;

    function setValidator(
        address _address
    ) external whenNotPaused onlyOwner {
        validator = _address;
    }

    // Set new season
    function setNewSeason() external onlyRole(MANAGEMENT_ROLE) {
        season++;
    }
     // Set new season
    function setNftRepair(uint256 _cost) external onlyRole(MANAGEMENT_ROLE) {
        nftRepair = _cost;
    }
    // Set fee mint Monster
    function setCostOfType(
        TypeMint _type,
        uint256[] memory cost
    ) external onlyRole(MANAGEMENT_ROLE) {
        if (_type == TypeMint.GENERAL_HASH) {
            costOfGeneral = cost;
        } else if (_type == TypeMint.GENESIS_HASH) {
            costOfGenesis = cost;
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            costOfExternal = cost;
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            costOfHashChip = cost;
        } else {
            revert("Unsupported type");
        }
    }

    // Set limit mint Monster
    function setLimitOfType(
        TypeMint _type,
        uint256 limit
    ) external onlyRole(MANAGEMENT_ROLE) {
        if (_type == TypeMint.GENERAL_HASH) {
            limitGeneral = limit;
        } else if (_type == TypeMint.GENESIS_HASH) {
            limitGenesis = limit;
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            limitExternal = limit;
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            limitHashChip = limit;
        } else {
            revert("Unsupported type");
        }
    }

    // Mint monster from GeneralHash
    function _fromGeneralHash(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = generalHashContract._numberOfRegenerations(season, _tokenId);
        require(
            times < limitGeneral,"Times limit"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_tokenId) ==
                msg.sender,"Wrong owner"
        );
        generalHashContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        if (
           times + 1 == limitGeneral
        ) {
            generalHashContract.burn(_tokenId);
        }
        return _createNFT(msg.sender, TypeMint.GENERAL_HASH);
    }

    // mint monster from GenesisHash
    function _fromGenesisHash(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = genesisHashContract._numberOfRegenerations(season, _tokenId);
        require(
            times < limitGenesis,"Times limit"
        );
        require(
            IERC721(address(genesisHashContract)).ownerOf(_tokenId) ==
                msg.sender,"Wrong owner"
        );
        genesisHashContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        return _createNFT(msg.sender, TypeMint.GENESIS_HASH);
    }

    // mint monster from External NFT
    function _fromExternalNFT(
        uint256 _chainId,
        address _address,
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = _timesRegenExternal[season][_chainId][_address][_tokenId];
        if(isERC721(_address)){
            require(
                IERC721(_address).ownerOf(_tokenId) == msg.sender,"Wrong owner"
                );
        }else if(isERC1155(_address)){
            require(
                IERC1155(_address).balanceOf(_address, _tokenId) > 0,"Balance not enough"
            );
        }
        
        require(
            times < limitExternal,"Times limit"
        );

        _timesRegenExternal[season][_chainId][_address][_tokenId]++;
        return _createNFT(msg.sender, TypeMint.EXTERNAL_NFT);
    }

    // mint monster from Hash Chip NFT
    function _fromHashChipNFT(
        uint256 _tokenId
    ) private returns (uint256) {
        uint256 times = hashChipNFTContract._numberOfRegenerations(season, _tokenId);
        require(
            times < limitHashChip,"Times limit"
        );
        require(
            IERC721(address(hashChipNFTContract)).ownerOf(_tokenId) == msg.sender,"Wrong owner"
        );
        hashChipNFTContract.setTimesOfRegeneration(season, _tokenId, times + 1);
        return _createNFT(msg.sender, TypeMint.REGENERATION_ITEM);
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
        TypeMint _type,
        address _addressContract,
        uint256 _chainId,
        address _account,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig
    ) external payable nonReentrant whenNotPaused {
        if (_isOAS) {
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
            treasuryContract.deposit{value: msg.value}(_cost);
        } else {
            uint256 cost = getFeeOfTokenId(_type, _chainId, _addressContract, _tokenId);
            tokenBaseContract.burnToken(msg.sender, cost*decimal );
        }

        uint256 tokenId;
        if (_type == TypeMint.GENERAL_HASH) {
            tokenId = _fromGeneralHash(_tokenId);
        } else if (_type == TypeMint.GENESIS_HASH) {
            tokenId = _fromGenesisHash(_tokenId);
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            tokenId = _fromExternalNFT( _chainId, _addressContract, _tokenId);
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            tokenId = _fromHashChipNFT(_tokenId);
        } else {
            revert("Unsupported type");
        }
        emit createNFTMonster(msg.sender, tokenId, _type);
    }

    /*
     * Create a Monster by type Free
     */
    function mintMonsterFree() external nonReentrant whenNotPaused {
        require(
            !_realdyFreeNFT[msg.sender],"Owned free NFT"
        );
        _realdyFreeNFT[msg.sender] = true;
        emit createNFTMonster(msg.sender, _createNFT(msg.sender, TypeMint.FREE), TypeMint.FREE);
    }

    /*
     * Create a Monster by type Free
     */
    function mintMonsterFromRegeneration(uint256 _itemId) external nonReentrant whenNotPaused {
        require(regenerationItem.isMintMonster(_itemId), "Wrong id");
        regenerationItem.burn(msg.sender, _itemId, 1);
        emit createNFTMonster(msg.sender, _createNFT(msg.sender, TypeMint.REGENERATION_ITEM), TypeMint.REGENERATION_ITEM);
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
        uint256[] memory _amount
    ) external nonReentrant whenNotPaused {
        require(_listItem.length == _amount.length, "Input error");
        if(_amount[0] != 0) {
            fusionItem.burnMultipleItem(_owner, _listItem, _amount);
        }
        require(
            ownerOf(_firstTokenId) == _owner,
            "The owner is not correct"
        );
        require(
            ownerOf(_lastTokenId) == _owner,
            "The owner is not correct"
        );
        bool lifeSpanFistMonster = getStatusMonster(_firstTokenId);
        bool lifeSpanLastMonster = getStatusMonster(_lastTokenId);
        if (!lifeSpanFistMonster) {
            monsterMemory.mint(_owner, _firstTokenId);
        }
        if (!lifeSpanLastMonster) {
            monsterMemory.mint(_owner, _lastTokenId);
        }
        _burn(_firstTokenId);
        _burn(_lastTokenId);
        emit fusionMultipleMonster(
            _owner,
            _createNFT(_owner, TypeMint.FUSION),
            _firstTokenId,
            _lastTokenId
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
        uint256[] memory _amount
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
            timesRegeneration1 < limitGenesis &&
                timesRegeneration2 < limitGenesis,
            "Exceed the allowed number of times"
        );

        genesisHashContract.setTimesOfRegeneration(season, _firstId, timesRegeneration1 + 1);
        genesisHashContract.setTimesOfRegeneration(season, _lastId, timesRegeneration2 + 1);
        emit fusionGenesisHashNFT(_owner, _firstId, _lastId, _createNFT(_owner, TypeMint.FUSION));
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
        uint256[] memory _amount
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
            timesRegeneration1 < limitGeneral &&
                timesRegeneration2 < limitGeneral,
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(season, _firstId, timesRegeneration1 + 1);
        genesisHashContract.setTimesOfRegeneration(season, _lastId, timesRegeneration2 + 1);

        if (timesRegeneration1 + 1 == limitGeneral) {
            generalHashContract.burn(_firstId);
        }
        if (timesRegeneration2 + 1 == limitGeneral) {
            generalHashContract.burn(_lastId);
        }
        emit fusionGeneralHashNFT(_owner, _firstId, _lastId, _createNFT(_owner, TypeMint.FUSION));
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
        uint256[] memory _amount
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
            timesGenesis < limitGenesis && timesGeneral < limitGeneral,
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(season, _genesisId, timesGenesis + 1);
        generalHashContract.setTimesOfRegeneration(season, _generalId, timesGeneral + 1);
        if (timesGeneral + 1 == limitGeneral) {
            generalHashContract.burn(_generalId);
        }
        emit fusionMultipleHashNFT(_owner, _genesisId, _generalId, _createNFT(_owner, TypeMint.FUSION));
    }

    /*
     * get Fee mint Monster of tokenId
     * @param _tokenId: tokenId
     */
    function _refreshTimesOfRegeneration(
        TypeMint _type,
        uint256 _chainId,
        address _address,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) internal {
        if (_isOAS) {
            treasuryContract.deposit{value: msg.value}(_cost);
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        if (_type == TypeMint.EXTERNAL_NFT) {
            require(
                _timesRegenExternal[season][_chainId][_address][
                    _tokenId
                ] == limitExternal,
                "Item being used"
            );
            _timesRegenExternal[season][_chainId][_address][_tokenId] = 0;
        } else if (_type == TypeMint.GENESIS_HASH) {
            require(
                genesisHashContract._numberOfRegenerations(season, _tokenId) == limitGenesis,
                "Item being used"
            );
            genesisHashContract.setTimesOfRegeneration(season, _tokenId, 0);
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            require(
                hashChipNFTContract._numberOfRegenerations(season, _tokenId) == limitHashChip,
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
        TypeMint _type,
        uint256 _chainId,
        address _address,
        uint256 _tokenId
    ) public view whenNotPaused returns (uint256 fee) {
        if (_type == TypeMint.EXTERNAL_NFT) {
            fee = costOfExternal[_timesRegenExternal[season][_chainId][_address][_tokenId]];
        } else if (_type == TypeMint.GENESIS_HASH) {
            fee = costOfExternal[genesisHashContract._numberOfRegenerations(season, _tokenId)];
        } else if (_type == TypeMint.GENERAL_HASH) {
            fee = costOfExternal[generalHashContract._numberOfRegenerations(season, _tokenId)];
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            fee = costOfExternal[hashChipNFTContract._numberOfRegenerations(season, _tokenId)];
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
        TypeMint _type,
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
    function createMonster(address _address, TypeMint _type, uint256 number ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        for(uint256 i=0;i<number;i++){
            _createNFT(_address, _type);
        }   
    }
}
