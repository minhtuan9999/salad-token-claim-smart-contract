// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./MonsterInterface.sol";

contract MonsterCore is MonsterInterface {
    // Payable address can receive Ether
    address payable public _treasuryAddress;
    // Season
    uint256 public season;

    uint256[] public costOfGenesis = [8, 9, 10, 11, 12];
    uint256[] public costOfGeneral = [8, 10, 12];
    uint256[] public costOfExternal = [8, 10, 12];
    uint256[] public costOfHashChip = [8, 10, 12];

    uint256 public limitGenesis = 5;
    uint256 public limitGeneral = 3;
    uint256 public limitExternal = 3;
    uint256 public limitHashChip = 3;

    // Check status mint nft free of address
    mapping(address => bool) public _realdyFreeNFT;
    // NFT detail: Season =>( TypeMint => (tokenId => number Of Regenerations))
    mapping(uint256 => mapping(TypeMint => mapping(uint256 => uint256)))
        public _numberOfRegenerations;

    // Mint monster from GeneralHash
    function _fromGeneralHash(
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) private returns (uint256) {
        uint256 timesRegeneration = _numberOfRegenerations[season][
            TypeMint.GENERAL_HASH
        ][_tokenId];
        require(
            timesRegeneration < limitGeneral,
            "Monster:::MonsterCore::_fromGeneralHash: Exceed the allowed number of times"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_tokenId) ==
                msg.sender,
            "Monster:::MonsterCore::_fromGeneralHash: GENERAL_HASH The owner is not correct"
        );
        if (_isOAS) {
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
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        _numberOfRegenerations[season][TypeMint.GENERAL_HASH][_tokenId]++;
        if (
            _numberOfRegenerations[season][TypeMint.GENERAL_HASH][_tokenId] ==
            limitGeneral
        ) {
            generalHashContract.burn(_tokenId);
        }
        uint256 tokenId = _createNFT(msg.sender, TypeMint.GENERAL_HASH);
        return tokenId;
    }

    // mint monster from GenesisHash
    function _fromGenesisHash(
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) private returns (uint256) {
        uint256 timesRegeneration = _numberOfRegenerations[season][
            TypeMint.GENESIS_HASH
        ][_tokenId];
        require(
            timesRegeneration < limitGenesis,
            "Monster:::MonsterCore::_fromGenesisHash: Exceed the allowed number of times"
        );
        require(
            IERC721(address(genesisHashContract)).ownerOf(_tokenId) ==
                msg.sender,
            "Monster:::MonsterCore::_fromGenesisHash: The owner is not correct"
        );

        if (_isOAS) {
            require(
                msg.value == _cost,
                "Monster:::MonsterCore::_fromGenesisHash: wrong msg value"
            );
            bool sent = _treasuryAddress.send(_cost);
            require(
                sent,
                "Monster:::MonsterCore::_fromGenesisHash: Failed to send Ether"
            );
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        _numberOfRegenerations[season][TypeMint.GENESIS_HASH][_tokenId]++;
        uint256 tokenId = _createNFT(msg.sender, TypeMint.GENESIS_HASH);
        return tokenId;
    }

    // mint monster from External NFT
    function _fromExternalNFT(
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) private returns (uint256) {
        uint256 timesRegeneration = _numberOfRegenerations[season][
            TypeMint.EXTERNAL_NFT
        ][_tokenId];
        require(
            externalNFTContract.ownerOf(_tokenId) == msg.sender,
            "Monster:::MonsterCore::_fromExternalNFT: The owner is not correct"
        );
        require(
            timesRegeneration < limitExternal,
            "Monster:::MonsterCore::_fromExternalNFT: Exceed the allowed number of times"
        );
        if (_isOAS) {
            require(
                msg.value == _cost,
                "Monster:::MonsterCore::_fromExternalNFT: wrong msg value"
            );
            bool sent = _treasuryAddress.send(_cost);
            require(
                sent,
                "Monster:::MonsterCore::_fromExternalNFT: Failed to send Ether"
            );
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        _numberOfRegenerations[season][TypeMint.EXTERNAL_NFT][_tokenId]++;
        uint256 tokenId = _createNFT(msg.sender, TypeMint.EXTERNAL_NFT);
        return tokenId;
    }

    // mint monster from Regeneration hash
    function _fromRegenerationNFT(uint256 _tokenId) internal returns (uint256) {
        item.burn(msg.sender, _tokenId, 1);
        uint256 tokenId = _createNFT(msg.sender, TypeMint.REGENERATION_ITEM);
        return tokenId;
    }

    // mint monster from Hash Chip NFT
    function _fromHashChipNFT(
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) private returns (uint256) {
        uint256 timesRegeneration = _numberOfRegenerations[season][
            TypeMint.HASH_CHIP_NFT
        ][_tokenId];
        require(
            timesRegeneration < limitHashChip,
            "Monster:::MonsterCore::_fromHashChipNFT: Exceed the allowed number of times"
        );
        require(
            hashChipNFTContract.ownerOf(_tokenId) == msg.sender,
            "Monster:::MonsterCore::_fromHashChipNFT: The owner is not correct"
        );

        if (_isOAS) {
            require(
                msg.value == _cost,
                "Monster:::MonsterCore::_fromHashChipNFT: wrong msg value"
            );
            bool sent = _treasuryAddress.send(_cost);
            require(
                sent,
                "Monster:::MonsterCore::_fromHashChipNFT: Failed to send Ether"
            );
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        uint256 tokenId = _createNFT(msg.sender, TypeMint.REGENERATION_ITEM);
        _numberOfRegenerations[season][TypeMint.HASH_CHIP_NFT][_tokenId]++;
        return tokenId;
    }

    // mint monster from Free NFT
    function _fromFreeNFT() internal returns (uint256) {
        require(
            !_realdyFreeNFT[msg.sender],
            "Monster:::MonsterCore::_fromFreeNFT: You have created free NFT"
        );
        uint256 tokenId = _createNFT(msg.sender, TypeMint.FREE);
        _realdyFreeNFT[msg.sender] = true;
        return tokenId;
    }

    function _mintMonster(
        TypeMint _type,
        uint256 _tokenId,
        bool isOAS,
        uint256 cost
    ) internal returns (uint256) {
        uint256 tokenId;
        if (_type == TypeMint.GENERAL_HASH) {
            tokenId = _fromGeneralHash(_tokenId, isOAS, cost);
        } else if (_type == TypeMint.GENESIS_HASH) {
            tokenId = _fromGenesisHash(_tokenId, isOAS, cost);
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            tokenId = _fromExternalNFT(_tokenId, isOAS, cost);
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            tokenId = _fromHashChipNFT(_tokenId, isOAS, cost);
        } else {
            revert("Monster:::MonsterCore::_mintMonster: Unsupported type");
        }
        return tokenId;
    }

    // fusion 2 Monster
    function _fusionNFT(
        address _owner,
        uint256 _firstTokenId,
        uint256 _lastTokenId
    ) private returns (uint256) {
        require(
            ownerOf(_firstTokenId) == _owner,
            "Monster:::MonsterCore::_fusionMonsterNFT: The owner is not correct"
        );
        require(
            ownerOf(_lastTokenId) == _owner,
            "Monster:::MonsterCore::_fusionMonsterNFT: The owner is not correct"
        );
        bool lifeSpanFistMonster = getStatusMonster(_firstTokenId);
        bool lifeSpanLastMonster = getStatusMonster(_lastTokenId);
        if (!lifeSpanFistMonster) {
            monsterMemory.mint(_owner, _firstTokenId);
        }
        if (!lifeSpanLastMonster) {
            monsterMemory.mint(_owner, _lastTokenId);
        }
        uint256 newTokenId = _createNFT(_owner, TypeMint.FUSION);
        _burn(_firstTokenId);
        _burn(_lastTokenId);
        return newTokenId;
    }

    // fusion monster nft
    function _fusionMonsterNFT(
        address _owner,
        uint256 _firstTokenId,
        uint256 _lastTokenId,
        uint256[] memory _itemId,
        uint256[] memory _amount
    ) internal returns (uint256) {
        require(
            _itemId.length == _amount.length,
            "Monster:::MonsterCore::_fusionMonsterNFT: Invalid input"
        );
        if (_itemId[0] != 0) {
            item.burnMultipleItem(_owner, _itemId, _amount);
        }
        uint256 tokenId = _fusionNFT(_owner, _firstTokenId, _lastTokenId);
        return tokenId;
    }

    // fusion monster by genesis hash
    function _fusionGenesisHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId,
        uint256[] memory _itemId,
        uint256[] memory _amount
    ) internal returns (uint256) {
        uint256 timesRegeneration1 = _numberOfRegenerations[season][
            TypeMint.GENESIS_HASH
        ][_firstId];
        uint256 timesRegeneration2 = _numberOfRegenerations[season][
            TypeMint.GENESIS_HASH
        ][_lastId];
        require(
            IERC721(address(genesisHashContract)).ownerOf(_firstId) == _owner,
            "Monster:::MonsterCore::_fusionGenesisHash: The owner is not correct"
        );
        require(
            IERC721(address(genesisHashContract)).ownerOf(_lastId) == _owner,
            "Monster:::MonsterCore::_fusionGenesisHash: The owner is not correct"
        );
        require(
            _itemId.length == _amount.length,
            "Monster:::MonsterCore::_fusionGenesisHash: Invalid input"
        );
        require(
            timesRegeneration1 < limitGenesis &&
                timesRegeneration2 < limitGenesis,
            "Monster:::MonsterCore::_fusionGenesisHash: Exceed the allowed number of times"
        );
        if (_itemId[0] != 0) {
            item.burnMultipleItem(_owner, _itemId, _amount);
        }
        uint256 newTokenId = _createNFT(_owner, TypeMint.FUSION);
        _numberOfRegenerations[season][TypeMint.GENESIS_HASH][_firstId]++;
        _numberOfRegenerations[season][TypeMint.GENESIS_HASH][_lastId]++;
        return newTokenId;
    }

    // fusion monster by general hash
    function _fusionGeneralHash(
        address _owner,
        uint256 _firstId,
        uint256 _lastId,
        uint256[] memory _itemId,
        uint256[] memory _amount
    ) internal returns (uint256) {
        uint256 timesRegeneration1 = _numberOfRegenerations[season][
            TypeMint.GENERAL_HASH
        ][_firstId];
        uint256 timesRegeneration2 = _numberOfRegenerations[season][
            TypeMint.GENERAL_HASH
        ][_lastId];
        require(
            IERC721(address(generalHashContract)).ownerOf(_firstId) == _owner,
            "Monster:::MonsterCore::_fusionGeneralHash: The owner is not correct"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_lastId) == _owner,
            "Monster:::MonsterCore::_fusionGeneralHash: The owner is not correct"
        );
        require(
            _itemId.length == _amount.length,
            "Monster:::MonsterCore::_fusionGeneralHash: Invalid input"
        );
        require(
            timesRegeneration1 < limitGeneral &&
                timesRegeneration2 < limitGeneral,
            "Monster:::MonsterCore::_fusionGeneralHash: Exceed the allowed number of times"
        );
        if (_itemId[0] != 0) {
            item.burnMultipleItem(_owner, _itemId, _amount);
        }
        uint256 newTokenId = _createNFT(_owner, TypeMint.FUSION);
        _numberOfRegenerations[season][TypeMint.GENERAL_HASH][_firstId]++;
        _numberOfRegenerations[season][TypeMint.GENERAL_HASH][_lastId]++;
        if (_numberOfRegenerations[season][TypeMint.GENERAL_HASH][_firstId] == limitGeneral) {
            generalHashContract.burn(_firstId);
        }
        if (_numberOfRegenerations[season][TypeMint.GENERAL_HASH][_lastId] == limitGeneral) {
            generalHashContract.burn(_lastId);
        }
        return newTokenId;
    }

    // fusion monster by general x genesis
    function _fusionMultipleHash(
        address _owner,
        uint256 _genesisId,
        uint256 _generalId,
        uint256[] memory _itemId,
        uint256[] memory _amount
    ) internal returns (uint256) {
        uint256 timesGenesis = _numberOfRegenerations[season][
            TypeMint.GENESIS_HASH
        ][_genesisId];
        uint256 timesGeneral = _numberOfRegenerations[season][
            TypeMint.GENERAL_HASH
        ][_generalId];
        require(
            IERC721(address(genesisHashContract)).ownerOf(_genesisId) == _owner,
            "Monster:::MonsterCore::_fusionMultipleHash: The owner is not correct"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_generalId) == _owner,
            "Monster:::MonsterCore::_fusionMultipleHash: The owner is not correct"
        );
        require(
            _itemId.length == _amount.length,
            "Monster:::MonsterCore::_fusionMultipleHash: Invalid input"
        );
        require(
            timesGenesis < limitGenesis && timesGeneral < limitGeneral,
            "Monster:::MonsterCore::_fusionMultipleHash: Exceed the allowed number of times"
        );
        if (_itemId[0] != 0) {
            item.burnMultipleItem(_owner, _itemId, _amount);
        }
        uint256 newTokenId = _createNFT(_owner, TypeMint.FUSION);
        _numberOfRegenerations[season][TypeMint.GENESIS_HASH][_genesisId]++;
        _numberOfRegenerations[season][TypeMint.GENERAL_HASH][_generalId]++;
        if (_numberOfRegenerations[season][TypeMint.GENERAL_HASH][_generalId] == limitGeneral) {
            generalHashContract.burn(_generalId);
        }
        return newTokenId;
    }

    /*
     * get Fee mint Monster of tokenId
     * @param _tokenId: tokenId
     */
    function _refreshTimesOfRegeneration(
        TypeMint _type,
        uint256 _tokenId,
        bool _isOAS,
        uint256 _cost
    ) internal {
        if (_isOAS) {
            require(
                msg.value == _cost,
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: wrong msg value"
            );
            bool sent = _treasuryAddress.send(_cost);
            require(
                sent,
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: Failed to send Ether"
            );
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        if (_type == TypeMint.EXTERNAL_NFT) {
            require(
                _numberOfRegenerations[season][TypeMint.EXTERNAL_NFT][
                    _tokenId
                ] == limitExternal,
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: Item being used"
            );
            _numberOfRegenerations[season][TypeMint.EXTERNAL_NFT][_tokenId] = 0;
        } else if (_type == TypeMint.GENESIS_HASH) {
            require(
                _numberOfRegenerations[season][TypeMint.GENESIS_HASH][
                    _tokenId
                ] == limitGenesis,
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: Item being used"
            );
            _numberOfRegenerations[season][TypeMint.GENESIS_HASH][_tokenId] = 0;
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            require(
                _numberOfRegenerations[season][TypeMint.HASH_CHIP_NFT][
                    _tokenId
                ] == limitHashChip,
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: Item being used"
            );
            _numberOfRegenerations[season][TypeMint.HASH_CHIP_NFT][
                _tokenId
            ] = 0;
        } else {
            revert(
                "Monster:::MonsterCore::_refreshTimesOfRegeneration: Unsupported type"
            );
        }
    }
}
