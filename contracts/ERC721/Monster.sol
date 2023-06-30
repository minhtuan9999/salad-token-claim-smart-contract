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
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IGeneralHash {
    //Increased Index
    function increasedIndex(uint256 tokenId) external;
}
interface IGenesisHash {
    //Increased Index
    function increasedIndex(uint256 tokenId) external;
}

interface IERC1155Item {
     function burn(address _from, uint256 _id, uint256 _amount) external;
} 
interface IHashChip {
     function burn(address _from, uint256 _id, uint256 _amount) external;
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
        HASH_CHIP_NFT,
        REGENERATION_ITEM,
        FREE,
        FUSION
    } 

    IERC20 tokenBaseContract;
    IERC721 externalNFTContract;
    IGenesisHash genesisHashContract;
    IGeneralHash generalHashContract;
    IERC721 hashChipNFTContract;
    IERC1155Item regenerationContract;

    // Count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    // Base URI
    string private _baseURIextended;
    // Fee genesis hash
    uint256 feeGenesisInWei = 0;
    // Payable address can receive Ether
    address payable public _treasuryAddress;

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
    event createNFTMonster(address _address, uint256 _tokenId, TypeMint _type);
    
    // Get list Tokens of address
    function getListTokenOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAdrress[_address].values();
    }

    // Set contract token OAS
    function setTreasuryAdress(
        address _address
    ) external onlyRole(MANAGERMENT_ROLE) {
        _treasuryAddress = payable(_address);
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
    // Set contract Genesis Hash
    function setRegenerationItem(
        IERC1155Item _regenerationContract
    ) external onlyRole(MANAGERMENT_ROLE) {
        regenerationContract = _regenerationContract;
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

    // mint monster from GeneralHash
    function _fromGeneralHash(uint256 _tokenId) public returns(uint256)  {
        require(
            IERC721(address(generalHashContract)).ownerOf(_tokenId) == msg.sender,
            "Monster::mintMonsterFromBox::GENERAL_HASH The owner is not correct"
        );
        generalHashContract.increasedIndex(_tokenId);
        uint256 tokenId = _createNFT(msg.sender, TypeMint.GENERAL_HASH);
        return tokenId;
    }

    // mint monster from GeneralHash
    function _fromGenesisHash(uint256 _tokenId) public returns (uint256) {
        require(
            IERC721(address(genesisHashContract)).ownerOf(_tokenId) == msg.sender,
            "Monster::mintMonsterFromBox::GENESIS_HASH The owner is not correct"
        );
        uint256 tokenId = _createNFT(msg.sender, TypeMint.GENESIS_HASH);
        return tokenId;
    }
    // mint monster from GeneralHash
    function _fromExternalNFT(uint256 _tokenId) public returns (uint256) {
        require(externalNFTContract.ownerOf(_tokenId) == msg.sender,
            "Monster::mintMonsterFromBox::EXTERNAL_NFT The owner is not correct");
        uint256 tokenId = _createNFT(msg.sender, TypeMint.EXTERNAL_NFT);
        return  tokenId;
    }
    // mint monster from GeneralHash
    function _fromRegenerationNFT(uint256 _tokenId) public returns (uint256) {
        regenerationContract.burn(msg.sender, _tokenId, 1);
        uint256 tokenId = _createNFT(msg.sender, TypeMint.REGENERATION_ITEM);
        return tokenId;
    }
    // mint monster from GeneralHash
    function _fromHashChipNFT(uint256 _tokenId) public returns (uint256) {
        require(externalNFTContract.ownerOf(_tokenId) == msg.sender,
            "Monster::mintMonsterFromBox::HASHCHIP_NFT The owner is not correct");
        uint256 tokenId = _createNFT(msg.sender, TypeMint.REGENERATION_ITEM);
        return tokenId;
    }
    // mint monster from GeneralHash
    function _fromFreeNFT() public returns (uint256) {
        require(!_realdyFreeNFT[msg.sender], "Monster::mintMonsterFromBox::FREE You have created free NFT");
        uint256 tokenId = _createNFT(msg.sender, TypeMint.FREE);
        _realdyFreeNFT[msg.sender] == true;
        return  tokenId;
    }

    function mintMonster(
        TypeMint _type,
        uint256 _tokenId
    ) external whenNotPaused {
        uint256 tokenId;
        if (_type == TypeMint.GENERAL_HASH) {
            tokenId = _fromGeneralHash(_tokenId);
        } else if (_type == TypeMint.GENESIS_HASH) {
            tokenId = _fromGenesisHash(_tokenId);
        } else if (_type == TypeMint.EXTERNAL_NFT) {
            tokenId = _fromExternalNFT(_tokenId);
        } else if (_type == TypeMint.REGENERATION_ITEM) {
            tokenId = _fromRegenerationNFT(_tokenId);
        } else if (_type == TypeMint.HASH_CHIP_NFT) {
            tokenId = _fromHashChipNFT(_tokenId);
        } else if (_type == TypeMint.FREE) {
            tokenId = _fromFreeNFT();
        }  else {
            revert("Monster::mintMonsterFromBox: Unsupported type");
        }
        emit createNFTMonster(msg.sender, tokenId, _type);
    }

    /*
     * mint a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn 
     * @param _lastTokenId: last tokenId fusion => burn
     */

    function mintFusion(
        address _address
    ) external onlyRole(MANAGERMENT_ROLE) returns (uint256) {
        return _createNFT(_address, TypeMint.FUSION);
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
        if(_monster[tokenId].typeMint == TypeMint.FREE) {
            return true;
        }
        return false;
    }
}
