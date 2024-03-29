// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract HashChipNFT is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    constructor() ERC721("HashChip NFT", "HashChipNFT") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }
    // Detail of token id
    struct HashChipDetail {
        uint256 tokenId;
        uint256 timesRegeneration;
    }
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;

    mapping(uint256 =>  mapping(uint256 => uint256)) public _numberOfRegenerations;
    mapping(uint256 => HashChipDetail) public hashChipDetail;

    // Event create HashChipNFT
    event createHashChipNFT(address _address, uint256 tokenId);

    // Get list Tokens of address
    function getListTokensOfAddress(
        address _address
    ) external view returns (uint256[] memory) {
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
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _listTokensOfAddress[to].add(firstTokenId);
        _listTokensOfAddress[from].remove(firstTokenId);
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

    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    /*
     * base mint a hash chip nft
     * @param _address: owner of NFT
     */
    function createNFT(
        address _address,
        uint256 _tokenId
    ) external nonReentrant onlyRole(MANAGEMENT_ROLE) {
        _mint(_address, _tokenId);
        emit createHashChipNFT(_address, _tokenId);
    }

    // get type of list Token
    function getTypeOfListToken(uint256[] memory _listToken) public view returns(HashChipDetail[] memory) {
        HashChipDetail[] memory listTypes = new HashChipDetail[](_listToken.length);
        for(uint256 i=0; i< _listToken.length; i++) {
            listTypes[i] = hashChipDetail[_listToken[i]];
        }
        return listTypes;
    }
    /*
     * burn a HashChipNFT
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external whenNotPaused {
        require(hasRole(MANAGEMENT_ROLE, _msgSender()) || ownerOf(_tokenId) == _msgSender(), "You not permission");
        _burn(_tokenId);
    }
    // set times regenerations
    function setTimesOfRegeneration(uint256 season, uint256 tokenId, uint256 times) external onlyRole(MANAGEMENT_ROLE) {
        _numberOfRegenerations[season][tokenId] = times;
        hashChipDetail[tokenId].timesRegeneration =times;
    }
}
