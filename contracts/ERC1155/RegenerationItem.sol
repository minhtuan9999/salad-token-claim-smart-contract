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

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 

        itemDetail[REGENERATION_HASH_OOO_R].amountLimit = 100;
        itemDetail[REGENERATION_HASH_RANDOM_R].amountLimit = 200;
    }
    // base metadata
    string public baseMetadata;

    struct ITEM_DETAIL {
        uint256 amountLimit;
        uint256 totalAmount;
    }

    uint8 public HASH_FRAGMENT_UC  = 0;
    uint8 public REGENERATION_HASH_OOO_R  = 1;
    uint8 public REGENERATION_HASH_RANDOM_R  = 2;
    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    mapping(uint256 => ITEM_DETAIL) public itemDetail;

    // EVENT
    event mintTrainingItem(
        address _addressTo,
        uint256 itemId,
        uint256 number,
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
    // set amount limit
    function setAmountLimit(uint256 itemId, uint256 _limit) public onlyRole(MANAGEMENT_ROLE) {
        itemDetail[itemId].amountLimit = _limit;
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
        if(_itemId == HASH_FRAGMENT_UC) {
            _mint(_addressTo, _itemId, _number, _data);
        }else{
            uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
            require(remain > 0, "RegenerationItem:: mint: exceeding");
            _mint(_addressTo, _itemId, _number, _data);
        }
        emit mintTrainingItem(_addressTo, _itemId,_number, _data);
    }
    
    function isMintMonster(uint256 _itemId) external view returns(bool) {
        return _itemId == REGENERATION_HASH_OOO_R|| _itemId == REGENERATION_HASH_RANDOM_R;
    }

    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }

}
