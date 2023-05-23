// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Monster is
    Ownable,
    ReentrancyGuard,
    ERC721Enumerable,
    AccessControl,
    Pausable
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // stored current packageId
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
    }

    // Optional mapping for token URIs
    mapping(address => EnumerableSet.UintSet) private _listTokenIdOfAddress;
    mapping(uint256 => uint256) private _countMint;
    mapping(uint256 => monsterDetail) public _monster;
    mapping(address => bool) private _realdyFreeNFT;

    //struct Monster
    struct monsterDetail {
        bool lifeSpan;
        bool isFree;
    }

    // Event create Monster
    event createNFTMonster(address _address, uint256 _tokenId, uint256 _type);
    // Event create Monster Free
    event createNFTMonsterFree(address _address, uint256 _tokenDi);
    // Event fusion Monster
    event fusionNFTMonster(
        address _address,
        uint256 _newNFTMonster,
        uint256 _firstTokenId,
        uint256 _lastTokenId
    );

    // Get list Tokens
    function getListTokenOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokenIdOfAddress[_address].values();
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
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokenIdOfAddress[to].add(firstTokenId);
        _listTokenIdOfAddress[from].remove(firstTokenId);
    }

    // Base URI
    string private _baseURIextended;

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
     * mint a Monster
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */

    function _createNFT(address _address) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _listTokenIdOfAddress[_address].add(tokenId);
        _monster[tokenId].lifeSpan = true;
        return tokenId;
    }

    /*
     * mint a Monster
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */

    function createNFT(
        address _address,
        uint256 _type
    ) external onlyRole(MANAGERMENT_ROLE) returns (uint256) {
        uint256 tokenId = _createNFT(_address);
        emit createNFTMonster(_address, tokenId, _type);
    }

    /*
     * mint a Monster
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */
    function createFreeNFT(
        address _address
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(!_realdyFreeNFT[_address], "Exist NFT Free of address");
        uint256 tokenId = _createNFT(_address);
        _monster[tokenId].isFree = true;
        _realdyFreeNFT[_address] = true;
        emit createNFTMonsterFree(_address, tokenId);
    }

    /*
     * fusion a Monster
     * @param _address: address of owner
     * @param _firstTokenId: first tokenId fusion => burn
     * @param _lastTokenId: last tokenId fusion => burn
     */

    function fusionNFT(
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
        require(_exists(tokenId), "Monster: Monster not exists");
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
        require(_exists(tokenId), "Monster: Monster not exists");
        _monster[tokenId].lifeSpan = status;
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function isFreeMonster(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Monster: Monster not exists");
        return _monster[tokenId].isFree;
    }
}
