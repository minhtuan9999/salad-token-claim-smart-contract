// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MonsterBase is
    Ownable,
    ERC721Enumerable,
    AccessControl,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // Count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE  = keccak256("MANAGEMENT_ROLE");
    // Base URI
    string private _baseURIextended;

    constructor() ERC721("Monster", "Monster") {
        _setRoleAdmin(MANAGEMENT_ROLE , MANAGEMENT_ROLE );
        _setupRole(MANAGEMENT_ROLE , _msgSender());
    }

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

    // Mapping list token of owner
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;
    // Infor monster
    mapping(uint256 => MonsterDetail) public _monster;
    //struct Monster
    struct MonsterDetail {
        bool lifeSpan;
        TypeMint typeMint;
    }

    /*
     * create Monster NFT
     * @param _address: address of owner
     * @param tokenId: tokenId of monster
     * @param _type: type mint NFT
     */
    event createNFTMonster(address _address, uint256 tokenId, TypeMint _type);

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
    event refreshTimesRegeneration(
        TypeMint _type,
        uint256 tokenId
    );
    /*
     * burn monster by id
     * @param tokenId: tokenId of nft
     */
    event burnMonster(uint256 tokenId);
    /*
     * set Status Monsters
     * @param tokenId: tokenId of nft
     * @param status: status of nft
     */
    event setStatusMonsters(uint256 tokenId,bool status);

    // Get list Tokens of address
    function getListTokenOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
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
        require(
            _monster[firstTokenId].typeMint != TypeMint.FREE,
            "Monster:::MonsterBase::_beforeTokenTransfer: NFT free is not transferrable"
        );

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokensOfAddress[to].add(firstTokenId);
        _listTokensOfAddress[from].remove(firstTokenId);
    }

    /*
     * setBase URI
     * @param baseURI_: baseURI_ of NFT
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    /*
     * base URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    /*
     * supports Interface
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*
     * pause contract ny Management 
     */
    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }
    
    /*
     * unpause contract ny Management 
     */
    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    /*
     * base mint a Monster
     * @param _address: owner of NFT
     */
    function _createNFT(
        address _address,
        TypeMint _type
    ) internal returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _listTokensOfAddress[_address].add(tokenId);
        _monster[tokenId].lifeSpan = true;
        _monster[tokenId].typeMint = _type;
        _tokenIds.increment();
        return tokenId;
    }

    /*
     * mint a Monster by fusion
     * @param _address: address of owner
     */
    function mintFusion(address _address) internal returns (uint256) {
        return _createNFT(_address, TypeMint.FUSION);
    }

    /*
     * burn a Monster
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external nonReentrant onlyRole(MANAGEMENT_ROLE ) {
        _burn(_tokenId);
        emit burnMonster(_tokenId);
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function getStatusMonster(uint256 _tokenId) public view returns (bool) {
        require(
            _exists(_tokenId),
            "Monster:::MonsterBase::getStatusMonster: Monster not exists"
        );
        return _monster[_tokenId].lifeSpan;
    }

    /*
     * set staus lifespan a Monster
     * @param _tokenId: tokenId of monster
     * @param _status: _status of monster
     */
    function setStatusMonster(
        uint256 _tokenId,
        bool _status
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE ) {
        require(
            _exists(_tokenId),
            "Monster:::MonsterBase::setStatusMonster: Monster not exists"
        );
        _monster[_tokenId].lifeSpan = _status;
        emit setStatusMonsters(_tokenId,_status);
    }

    /*
     * check monster is Free
     * @param _tokenId: tokenId
     */
    function isFreeMonster(uint256 _tokenId) external view returns (bool) {
        require(
            _exists(_tokenId),
            "Monster:::MonsterBase::isFreeMonster: Monster does not exist"
        );
        return _monster[_tokenId].typeMint == TypeMint.FREE;
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
        TypeMint _type,
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
        TypeMint _type,
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
