// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Monster/MonsterCore.sol";

contract Monster is MonsterCore {
    // Validator
    address private validator;
    // Decimal
    uint256 public decimal = 10^18;
    // Status signature
    mapping(bytes => bool) public _isSigned;

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

    // Set new season
    function setNewSeason() external onlyRole(MANAGEMENT_ROLE) {
        season++;
    }

    // Set fee mint Monster
    function initSetCostOfType(
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
            revert("Monster:::MonsterCore::setCostOfType: Unsupported type");
        }
    }

    // Set limit mint Monster
    function initSetLimitOfType(
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
            revert("Monster:::MonsterCore::setLimitOfType: Unsupported type");
        }
    }

    // Set address Monster Treasury
    function initSetTreasuryAdress(
        address _address
    ) external onlyRole(MANAGEMENT_ROLE) {
        _treasuryAddress = payable(_address);
    }

    function initSetValidator(
        address _address
    ) external whenNotPaused onlyOwner {
        validator = _address;
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
                "Monster:::Monster::mintMonster: Deadline exceeded"
            );
            require(
                !_isSigned[_sig],
                "Monster:::Monster::mintMonster: Signature used"
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
                "Monster:::Monster::mintMonster: Validator fail signature"
            );
            require(
                msg.value == _cost,
                "Monster:::MonsterCore::_fromGeneralHash: wrong msg value"
            );
            bool sent = _treasuryAddress.send(_cost);
            require(
                sent,
                "Monster:::MonsterCore::_fromGeneralHash: Failed to send Ether"
            );
        } else {
            uint256 cost = getFeeOfTokenId(_type, _tokenId);
            tokenBaseContract.burnToken(msg.sender, cost*decimal );
        }

        uint256 tokenId = _mintMonster(_type, _tokenId);
        emit createNFTMonster(msg.sender, tokenId, _type);
    }

    /*
     * Create a Monster by type Free
     */
    function mintMonsterFree() external nonReentrant whenNotPaused {
        uint256 tokenId = _fromFreeNFT();
        emit createNFTMonster(msg.sender, tokenId, TypeMint.FREE);
    }

    /*
     * Create a Monster by type Free
     */
    function mintMonsterFromRegeneration(
        uint256 _tokenId
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = _fromRegenerationNFT(_tokenId);
        emit createNFTMonster(msg.sender, tokenId, TypeMint.REGENERATION_ITEM);
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
        uint256 _lastTokenId
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = _fusionMonsterNFT(
            _owner,
            _firstTokenId,
            _lastTokenId
        );
        emit fusionMultipleMonster(
            _owner,
            tokenId,
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
        uint256 _lastId
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = _fusionGenesisHash(
            _owner,
            _firstId,
            _lastId
        );
        emit fusionGenesisHashNFT(_owner, _firstId, _lastId, tokenId);
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
        uint256 _lastId
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = _fusionGeneralHash(
            _owner,
            _firstId,
            _lastId
        );
        emit fusionGeneralHashNFT(_owner, _firstId, _lastId, tokenId);
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
        uint256 _generalId
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = _fusionMultipleHash(
            _owner,
            _genesisId,
            _generalId
        );
        emit fusionMultipleHashNFT(_owner, _genesisId, _generalId, tokenId);
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
        address _account,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig
    ) external payable nonReentrant whenNotPaused {
        require(
            _deadline > block.timestamp,
            "Monster:::Monster::mintMonster: Deadline exceeded"
        );
        require(
            !_isSigned[_sig],
            "Monster:::Monster::mintMonster: Signature used"
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
            "Monster:::Monster::mintMonster: Validator fail signature"
        );
        _refreshTimesOfRegeneration(_type, _tokenId, _isOAS, _cost);
    }

    /*
     * get Fee mint Monster by TyMint & tokenId
     * @param _type: TypeMint
     * @param _tokenId: tokenId
     */
    function getFeeOfTokenId(
        TypeMint _type,
        uint256 _tokenId
    ) public view whenNotPaused returns (uint256 fee) {
        if (_type == TypeMint.EXTERNAL_NFT) {
            uint256 countRegeneration = _numberOfRegenerations[season][
                TypeMint.EXTERNAL_NFT
            ][_tokenId];
            fee = costOfExternal[countRegeneration];
        } else if (_type == TypeMint.GENESIS_HASH) {
            uint256 countRegeneration = _numberOfRegenerations[season][
                TypeMint.GENESIS_HASH
            ][_tokenId];
            fee = costOfExternal[countRegeneration];
        } else if (_type == TypeMint.GENERAL_HASH) {
            uint256 countRegeneration = _numberOfRegenerations[season][
                TypeMint.GENERAL_HASH
            ][_tokenId];
            fee = costOfExternal[countRegeneration];
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            uint256 countRegeneration = _numberOfRegenerations[season][
                TypeMint.HASH_CHIP_NFT
            ][_tokenId];
            fee = costOfExternal[countRegeneration];
        } else {
            revert("Monster:::MonsterCore::getFeeOfTokenId: Unsupported type");
        }
    }
}
