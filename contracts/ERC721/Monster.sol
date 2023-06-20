// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IGeneralHash {
    //Increased Index
    function increasedIndex(uint256 tokenId) external;

    //Burn General Hash
    function burn(uint256 _tokenId) external;

    //Get Index General Hash
    function getIndexOfTokenID(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IGenesisHash {
    //Increased Index
    function increasedIndex(uint256 tokenId) external;

    //Burn Genesis Hash
    function burn(uint256 _tokenId) external;

    //Get Index Genesis Hash
    function getIndexOfTokenID(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract Monster is Ownable, ERC721Enumerable, AccessControl, Pausable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

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
        HASH_CHIP_NFT
        REGENERATION_ITEM,
        FREE
    }

    IERC20 tokenBaseContract;
    IERC721 externalNFTContract;
    IGenesisHash genesisHashContract;
    IGeneralHash generalHashContract;
    IERC721 hashChipNFTContract;
    IERC1155 regenerationItemContract;

    // Count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    // Base URI
    string private _baseURIextended;
    // Fee genesis hash
    uint256 feeGenesisInWei = 0;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
    }

    // Mapping list token of owner
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAdrress;

    // Infor monster
    mapping(uint256 => MonsterDetail) public _monster;
    
    // check status mint nft free of address
    mapping(address => bool) private _realdyFreeNFT;

    //struct Monster
    struct MonsterDetail {
        bool lifeSpan;
        TypeMint typeMint;
    }


    // Event create Monster
    event createNFTMonster(address _address, uint256 _tokenId, uint256 _type);
    // Event create Monster Free
    event createNFTMonsterFree(address _address, uint256 _tokenDi);

    // Get list Tokens of address
    function getListTokenOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAdrress[_address].values();
    }

    // Set contract token OAS
    function setTokenBase(
        IERC20 _tokenBase
    ) external onlyRole(MANAGERMENT_ROLE) {
        tokenBaseContract = _tokenBase;
    }

    // Set contract External NFT
    function setExternalNFT(
        IERC721 externalNFT
    ) external onlyRole(MANAGERMENT_ROLE) {
        externalNFTContract = externalNFT;
    }

    // Set contract General Hash
    function setGeneralHash(
        IGeneralHash generalHash
    ) external onlyRole(MANAGERMENT_ROLE) {
        generalHashContract = generalHash;
    }

    // Set contract Genesis Hash
    function setGenesisHash(
        IGenesisHash genesisHash
    ) external onlyRole(MANAGERMENT_ROLE) {
        genesisHashContract = genesisHash;
    }

    // Set contract Hash Chip NFT
    function setHashChip(
        IERC721 hashChip
    ) external onlyRole(MANAGERMENT_ROLE) {
        hashChipNFTContract = hashChip;
    }

    // Set fee mint from genesis hash
    function setFeeGenesis(
        uint256 feeInWei
    ) external onlyRole(MANAGERMENT_ROLE) {
        feeGenesisInWei = feeInWei;
    }

    /**
     *@dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        require(_monster[firstTokenId].typeMint != TypeMint.FREE, "NFT free is not transferrable");
        
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokensOfAdrress[to].add(firstTokenId);
        _listTokensOfAdrress[from].remove(firstTokenId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function pause() public onlyRole(MANAGERMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGERMENT_ROLE) {
        _unpause();
    }

    function mintMonsterFromBox(
        TypeMint _type,
        uint256 _tokenId
    ) external whenNotPaused {
        uint256 tokenId;
        if (_type == TypeMint.GENERAL_HASH) {
            require(
                generalHashContract.ownerOf(_tokenId) == msg.sender,
                "Monster::mintMonsterFromBox::GENERAL_HASH The owner is not correct"
            );
            generalHashContract.increasedIndex(_tokenId);
            uint8 indexHash = getIndexOfTokenID(_tokenId);
            tokenId = _createNFT(msg.sender, TypeMint.GENERAL_HASH);
            if (indexHash == 5) {
                generalHashContract.burn(_tokenId);
            }
        } else if (_type == TypeMint.GENESIS_HASH) {
            require(
                genesisHashContract.ownerOf(_tokenId) == msg.sender,
                "Monster::mintMonsterFromBox::GENESIS_HASH The owner is not correct"
            );
            uint8 indexHash = getIndexOfTokenID(_tokenId);
            if (indexHash > 5 && feeGenesis > 0) {
                // Transfer OAS amount to contract
                require(
                    tokenBaseContract.transferFrom(
                        msg.sender,
                        address(this),
                        feeGenesisInWei
                    ),
                    "Monster::mintMonsterFromBox::GENESIS_HASH: Transfering to the contract failed"
                );
            }
            genesisHashContract.increasedIndex(_tokenId);

            tokenId = _createNFT(msg.sender, TypeMint.GENESIS_HASH);
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            require(
                externalNFTContract.ownerOf(_tokenId) == msg.sender,
                "Monster::mintMonsterFromBox::EXTERNAL_NFT The owner is not correct"
            );
            generalHashContract.increasedIndex(_tokenId);
            uint8 indexHash = getIndexOfTokenID(_tokenId);
            tokenId = _createNFT(msg.sender, TypeMint.EXTERNAL_NFT);
        } else if (_type == TypeMint.REGENERATION_ITEM) {
            //
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            //
        } else if (_type == TypeMint.Free) {
            //
        }  else {
            revert("Monster::mintMonsterFromBox: Unsupported type");
        }
        emit createNFTMonster(msg.sender, tokenId, _type);
    }

    /*
     * base mint a Monster
     * @param _address: owner of NFT
     */

    function _createNFT(
        address _address,
        TypeMint _type
    ) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _listTokensOfAdrress[_address].add(tokenId);
        _monster[tokenId].lifeSpan = true;
        _monster[tokenId].typeMint = _type;
        _tokenIds.increment();
        return tokenId;
    }

    /*
     * mint a Monster
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */
    function createFreeNFT(
        address _address
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            !_realdyFreeNFT[_address],
            "Monster:: CreateFreeNFT: Exist NFT Free of address"
        );
        uint256 tokenId = _createNFT(_address);
        _monster[tokenId].isFree = true;
        _realdyFreeNFT[_address] = true;
        emit createNFTMonsterFree(_address, tokenId);
    }

    /*
     * mint a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */

    function mint(
        address _address
    ) external onlyRole(MANAGERMENT_ROLE) returns (uint256) {
        return _createNFT(_address);
    }

    /*
     * burn a Monster
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external onlyRole(MANAGERMENT_ROLE) {
        _burn(_tokenId);
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function getStatusMonster(uint256 tokenId) external view returns (bool) {
        require(
            _exists(tokenId),
            "Monster:: GetStatusMonster: Monster not exists"
        );
        return _monster[tokenId].lifeSpan;
    }

    /*
     * set staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function setStatusMonster(
        uint256 tokenId,
        bool status
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(
            _exists(tokenId),
            "Monster:: setStatusMonster: Monster not exists"
        );
        _monster[tokenId].lifeSpan = status;
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function isFreeMonster(uint256 tokenId) external view returns (bool) {
        require(
            _exists(tokenId),
            "Monster:: isFreeMonster: Monster not exists"
        );
        return _monster[tokenId].isFree;
    }
}
