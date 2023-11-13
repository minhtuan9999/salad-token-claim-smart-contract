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

contract Monster is
    Ownable,
    ERC721Enumerable,
    AccessControl,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    Counters.Counter _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    string _baseURIextended;

    constructor() ERC721("Monster", "Monster") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }

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

    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    mapping(uint256 => MonsterDetail) public _monster;
    mapping(address => bool) public _hasFreeNFT;
    //struct Monster
    struct MonsterDetail {
        bool lifeSpan;
        uint8 typeMint;
    }

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
    event setStatusMonsters(uint256 tokenId, bool status);

    event MintMonster(address owner, uint256 tokenId, uint8 _type);
    event MintFreeMonster(address owner, uint256 tokenId);

    // Get list Tokens of address
    function getListTokenOfAddress(address _address)
        public
        view
        returns (uint256[] memory)
    {
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
        if (to != address(0)) {
            require(
                _monster[firstTokenId].typeMint != FREE,
                "NFT free is not transferrable"
            );
        }

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokensOfAddress[to].add(firstTokenId);
        _listTokensOfAddress[from].remove(firstTokenId);
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    /*
     * base mint a Monster
     * @param _address: owner of NFT
     */
    function mintMonster(address _address, uint8 _type)
        external
        onlyRole(MANAGEMENT_ROLE)
        returns (uint256)
    {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _monster[tokenId].lifeSpan = true;
        _monster[tokenId].typeMint = _type;
        if (_type == FREE) {
            require(!_hasFreeNFT[_address], "You owned free NFT");
            _hasFreeNFT[_address] = true;
        }
        _tokenIds.increment();
        emit MintMonster(_address, tokenId, _type);
        return tokenId;
    }

    /*
     * burn a Monster
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external nonReentrant whenNotPaused
    {
        require(msg.sender == ownerOf(_tokenId) || hasRole(MANAGEMENT_ROLE, msg.sender),
                "You not permission"
        );
        _burn(_tokenId);
        emit burnMonster(_tokenId);
    }

    /*
     * status lifespan a Monster
     * @param _tokenId: tokenId
     */
    function getStatusMonster(uint256 _tokenId) external view returns (bool) {
        require(_exists(_tokenId), "Monster not exists");
        return _monster[_tokenId].lifeSpan;
    }

    /*
     * set staus lifespan a Monster
     * @param _tokenId: tokenId of monster
     * @param _status: _status of monster
     */
    function setStatusMonster(uint256 _tokenId, bool _status)
        external
        nonReentrant
        whenNotPaused
        onlyRole(MANAGEMENT_ROLE)
    {
        require(_exists(_tokenId), "Monster not exists");
        _monster[_tokenId].lifeSpan = _status;
        emit setStatusMonsters(_tokenId, _status);
    }

    /*
     * check monster is Free
     * @param _tokenId: tokenId
     */
    function isFreeMonster(uint256 _tokenId)
        external
        view
        whenNotPaused
        returns (bool)
    {
        require(_exists(_tokenId), "Monster does not exist");
        return _monster[_tokenId].typeMint == FREE;
    }
}
