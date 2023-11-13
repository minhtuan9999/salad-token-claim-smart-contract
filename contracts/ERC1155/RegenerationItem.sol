//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RegenerationItem is ERC1155, AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;
    uint256 public currentId;

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 
        _initDefautItems();
    }
    // base metadata
    string public baseMetadata;

    struct ITEM_DETAIL {
        string name;
        uint8 typeItem;
        uint256 amountLimit;
        uint256 totalAmount;
    }

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    mapping(uint256 => ITEM_DETAIL) public itemDetail;

    // EVENT
    event mintRegenerationItem(
        address _addressTo,
        uint256 itemId,
        uint256 number,
        bytes data
    );
    event mintBatchRegenerationItem(
        address _addressTo,
        uint256[] itemId,
        uint256[] number,
        bytes data
    );
    event burnItem(address _from, uint256 _id, uint256 _amount);
    event burnBathItem(address _from, uint256[] _id, uint256[] _amount);
    
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
    // set item detail
    function setItemDetail(
        uint256 itemId,
        string memory name,
        uint8 typeItem,
        uint256 _limit
    ) public onlyRole(MANAGEMENT_ROLE) {
        require(itemId < currentId, "TrainingItem::setItemDetail: Unsupported itemId");
        itemDetail[itemId].name = name;
        itemDetail[itemId].typeItem = typeItem;
        itemDetail[itemId].amountLimit = _limit;
    }

    // add training item
    function addTrainingItem(
        string memory name,
        uint8 typeItem,
        uint256 _limit
    ) public onlyRole(MANAGEMENT_ROLE) {
        uint256 itemId = currentId;
        itemDetail[itemId].name = name;
        itemDetail[itemId].typeItem = typeItem;
        itemDetail[itemId].amountLimit = _limit;
        currentId++;
    }
    // Override _beforeTokenTransfer
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        for(uint256 i = 0; i< ids.length; i++){
            if(from != address(0)) {
                require(itemDetail[ids[i]].typeItem != 4, "RegenerationItem::_beforeTokenTransfer: Items cannot be transferred");
                if((balanceOf(from, ids[i]) - amounts[i]) == 0) {
                    _listTokensOfAddress[from].remove(ids[i]);
                }
            }
            if(to != address(0)) {
                _listTokensOfAddress[to].add(ids[i]);
            }
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // get list item of address
    function getListItemOfAddress(address _address) public view returns(uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    // Update total amount
    function _updateTotalAmount(
        uint256[] memory _itemId,
        uint256[] memory _number
    ) internal {
        for (uint i = 0; i < _itemId.length; i++) {
            require(
                itemDetail[_itemId[i]].typeItem != 0,
                "RegenerationItem::_updateTotalAmount: Unsupported itemId"
            );
            if(itemDetail[_itemId[i]].typeItem != 0 && itemDetail[_itemId[i]].amountLimit == 0) continue;
            uint256 remain = itemDetail[_itemId[i]].amountLimit - itemDetail[_itemId[i]].totalAmount;
            require(remain >= _number[i], "RegenerationItem::_updateTotalAmount: exceeding");
            itemDetail[_itemId[i]].totalAmount = itemDetail[_itemId[i]].totalAmount + _number[i];
        }
    }

    /**
     * @dev Mint monster item.
     * @param _addressTo: address 
     * @param _itemId: itemId
     * @param _number: number of item
     * @param _data: data of item
     */
    function mint(
        address _addressTo,
        uint256 _itemId,
        uint256 _number,
        bytes memory _data
    ) external onlyRole(MANAGEMENT_ROLE) {
        require(_itemId < 3, "RegenerationItem::mint: Unsupported itemId");
        if(itemDetail[_itemId].typeItem != 0 && itemDetail[_itemId].amountLimit == 0) {
            _mint(_addressTo, _itemId, _number, _data);
        } else{
            uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
            require(remain >= _number, "RegenerationItem:: mint: exceeding");
            _mint(_addressTo, _itemId, _number, _data);
        }
        emit mintRegenerationItem(_addressTo, _itemId,_number, _data);
    }

        /**
     * @dev Mint multiple monster item.
     * @param _addressTo: address
     * @param _itemId: itemId
     * @param _number: number of item
     */
    function mintMultipleItem(
        address _addressTo,
        uint256[] memory _itemId,
        uint256[] memory _number
    ) external onlyRole(MANAGEMENT_ROLE) {
        _updateTotalAmount(_itemId, _number);
        _mintBatch(_addressTo, _itemId, _number, "");
        emit mintBatchRegenerationItem(_addressTo, _itemId, _number, "");
    }
    
    function isMintMonster(uint256 _itemId) external pure returns(bool) {
        return (_itemId == 1|| _itemId == 2);
    }

    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }

    function _initDefautItems() private {
        itemDetail[0].name = "HASH_FRAGMENT_UC";
        itemDetail[0].typeItem = 2;

        itemDetail[1].name = "REGENERATION_HASH_OOO_R";
        itemDetail[1].typeItem = 3;

        itemDetail[2].name = "REGENERATION_HASH_RANDOM_R";
        itemDetail[2].typeItem = 3;

        itemDetail[3].name = "HASH_FRAGMENT_R";
        itemDetail[3].typeItem = 3;

        itemDetail[4].name = "HASH_FRAGMENT_B";
        itemDetail[4].typeItem = 4;

        itemDetail[5].name = "REGENERATION_HASH_B";
        itemDetail[5].typeItem = 4;

        currentId = 6;
    }
}
