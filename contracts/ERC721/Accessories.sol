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

interface IMonsterItem {
    function burn(address _from, uint256 _id, uint256 _amount) external;
    function mint(
        address _addressTo,
        uint256 _itemType,
        uint256 _collectionType,
        uint256 _number,
        bytes memory _data
    ) external;

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external;
}

contract Accessories is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard {
    IMonsterItem item;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // stored current tokenId
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    constructor() ERC721("Accessories", "Accessories") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    // Event create Accessories
    event createAccessories(address _address, uint256 _tokenId, uint256 _type);
    /*
     * create Accessories by material
     * @param _owner: address of owner
     * @param materialId: id of material item
     * @param newTokenId: new tokenId of Accessories
     */
    event createAccessoriesByItems(
        address _owner,
        uint256[] materialId,
        uint256 newTokenId
    );

    // Get holder Tokens
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    // Set monster contract address
    function setMonsterItem(
        IMonsterItem _item
    ) external onlyRole(MANAGEMENT_ROLE) {
        item = _item;
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
     * base mint a Accessories
     * @param _address: owner of NFT
     */
    function _createNFT(address _address) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _listTokensOfAddress[_address].add(tokenId);
        return tokenId;
    }

    /*
     * mint a Accessories
     * @param _address: owner of NFT
     */
    function createNFT(
        address _address,
        uint256 _type
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 tokenId = _createNFT(_address);
        emit createAccessories(_address, tokenId, _type);
    }

    /*
     * mint a Accessories by item material
     * @param _materialId: list material id
     * @param _number: number of material id
     */
    function createAccessoriesByItem(
        uint256[] memory _materialId,
        uint256[] memory _number
    ) external nonReentrant whenNotPaused {
        require(
            _materialId.length == _number.length,"Invalid input"
        );
        item.burnMultipleItem(msg.sender, _materialId, _number);
        uint256 tokenId = _createNFT(msg.sender);
        emit createAccessoriesByItems(msg.sender, _materialId, tokenId);
    }

    /*
     * burn Accessories
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external nonReentrant whenNotPaused{
        require(hasRole(MANAGEMENT_ROLE, _msgSender())|| ownerOf(_tokenId) == _msgSender(), "You not owner!");
        _burn(_tokenId);
    }
}
