// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IMonsterItem {
    // burn item from tokenid
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

contract Accessories is Ownable, ERC721Enumerable, AccessControl, Pausable {
    IMonsterItem item;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // stored current packageId
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    constructor() ERC721("Accessories", "Accessories") {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
    }

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAdrress;
    // Event create Accessories
    event createAccessories(address _address, uint256 _tokenId, uint256 _type);
    /*
     * create Accessories From material
     * @param _owner: address of owner
     * @param _materialId: id of material item
     * @param _newTokenId: new tokenId of Accessories
     */
    event createAccessoriesNFT(
        address _owner,
        uint256[] _materialId,
        uint256 _newTokenId
    );

    // Get holder Tokens
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAdrress[_address].values();
    }

    // Set monster contract address
    function setMonsterItem(
        IMonsterItem _item
    ) external onlyRole(MANAGERMENT_ROLE) {
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
        _listTokensOfAdrress[to].add(firstTokenId);
        _listTokensOfAdrress[from].remove(firstTokenId);
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
     * base mint a Accessories
     * @param _address: owner of NFT
     */
    function _createNFT(address _address) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _listTokensOfAdrress[_address].add(tokenId);
        return tokenId;
    }

    /*
     * mint a Accessories
     * @param _address: owner of NFT
     */
    function createNFT(
        address _address,
        uint256 _type
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 tokenId = _createNFT(_address);
        emit createAccessories(_address, tokenId, _type);
    }

    /*
     * mint a Accessories
     * @param _materialId: list material id
     * @param _number: number of material id
     */
    function createAccessoriesByItem(
        uint256[] memory _materialId,
        uint256[] memory _number
    ) external whenNotPaused {
        require(
            _materialId.length == _number.length,
            "Accessories::createAccessoriesByItem: Invalid input"
        );
        item.burnMultipleItem(msg.sender, _materialId, _number);
        uint256 tokenId = _createNFT(msg.sender);
        emit createAccessoriesNFT(msg.sender, _materialId, tokenId);
    }

    /*
     * burn Accessories
     * @param _tokenId: tokenId burn
     */
    function burn(
        uint256 _tokenId
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _burn(_tokenId);
    }
}
