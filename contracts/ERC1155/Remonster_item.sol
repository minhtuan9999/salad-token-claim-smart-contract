//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RemonsterItem is ERC1155, AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    using Strings for uint256;
    uint256 private constant COLLECTION_TYPE_OFFSET = 10000; // Offset for collection types

    uint256 public constant TRAINING_ITEM = 1; // Training item collection
    uint256 public constant ENHANCE_ITEM = 2; // Enhance item collection
    uint256 public constant FUSION_ITEM = 3; // Fusion item collection
    uint256 public constant REGENERATION_ITEM = 4; // Regeneration item collection

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata;
    }
    // base metadata
    string public baseMetadata;
    // detail tokenId
    mapping (uint256 => detail) public _tokenDetail;
    // get tokenid of collectionType & itemType 
    mapping (uint256 => mapping(uint256 => uint256)) public _tokenIdOfType;
    
    // struct detail tokenId
    struct detail {
        uint256 collectionType;
        uint256 itemType;
    }
    // EVENT
    event mintMonsterItems(
        address _addressTo,
        uint256 itemId,
        uint256 itemType,
        uint256 collectionType,
        uint256 number,
        bytes data
    );
    event burnItem(address _from, uint256 _id, uint256 _amount);
    event burnBathItem(address _from, uint256[] _id, uint256[] _amount);
    event createRegenerationNFT(
        address _owner,
        uint256 _itemId,
        uint256 _fragmentId
    );
    
    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return string(abi.encodePacked(baseMetadata, tokenId.toString()));
    }

    function setBaseMetadata(string memory _baseMetadata) public onlyOwner {
        baseMetadata = _baseMetadata;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*
     * mint a Training item
     * @param addressTo: owner of NFT
     * @oaram _itemType: id of item
     * @oaram _collectionType: id of collection
     * @param number: number NFT
     * @param data: information of NFT
     */
    function _mintItem(
        address _addressTo,
        uint256 _itemType,
        uint256 _collectionType,
        uint256 _number,
        bytes memory _data
    ) private returns (uint256) {
        uint256 collectionId = _collectionType * COLLECTION_TYPE_OFFSET;
        uint256 itemId = collectionId + _itemType;
        _mint(_addressTo, itemId, _number, _data);
        _tokenDetail[itemId].collectionType = _collectionType;
        _tokenDetail[itemId].itemType = _itemType;
        _tokenIdOfType[_collectionType][_itemType] = itemId;
        return itemId;
    }
    /*
     * mint a Training item
     * @param addressTo: owner of NFT
     * @oaram _itemType: id of item
     * @oaram _collectionType: id of collection
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mint(
        address _addressTo,
        uint256 _itemType,
        uint256 _collectionType,
        uint256 _number,
        bytes memory _data
    ) external onlyRole(MANAGEMENT_ROLE) {
        uint256 itemId = _mintItem(_addressTo,_itemType,_collectionType,_number,_data);
        emit mintMonsterItems(_addressTo, itemId, _itemType, _collectionType, _number, _data);
    }
    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external {
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }
    
    /*
     * Create Regeneration
     * @param _itemType: type of item
     * @param _collectionType: type of collection
     * @param _hashFragmentId: id of fragment
     * @param _amount: number of fragment
     * @param _data: data of Regeneration
     */
    function createRegeneration(
        uint256 _itemType,
        uint256 _collectionType,
        uint256 _hashFragmentId, 
        uint256 _amount, 
        bytes memory _data
    ) external onlyRole(MANAGEMENT_ROLE) {
        uint256 itemId = _mintItem(msg.sender, _itemType, _collectionType, _amount, _data);
        _burn(msg.sender, _hashFragmentId, _amount);
        emit createRegenerationNFT(msg.sender, itemId, _hashFragmentId);
    } 

}
