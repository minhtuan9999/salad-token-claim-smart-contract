//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract EhanceItem is ERC1155, AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 

        itemDetail[HP_SEED_C].amountLimit = 1500;
        itemDetail[HP_SEED_UC].amountLimit = 300;
        itemDetail[HP_SEED_R].amountLimit = 60;

        itemDetail[STR_SEED_C].amountLimit = 1500;
        itemDetail[STR_SEED_UC].amountLimit = 300;
        itemDetail[STR_SEED_R].amountLimit = 60;

        itemDetail[INT_SEED_C].amountLimit = 1500;
        itemDetail[INT_SEED_UC].amountLimit = 300;
        itemDetail[INT_SEED_R].amountLimit = 60;

        itemDetail[DEX_SEED_C].amountLimit = 1500;
        itemDetail[DEX_SEED_UC].amountLimit = 300;
        itemDetail[DEX_SEED_R].amountLimit = 60;

        itemDetail[AGI_SEED_C].amountLimit = 1500;
        itemDetail[AGI_SEED_UC].amountLimit = 300;
        itemDetail[AGI_SEED_R].amountLimit = 60;

        itemDetail[VIT_SEED_C].amountLimit = 1500;
        itemDetail[VIT_SEED_UC].amountLimit = 300;
        itemDetail[VIT_SEED_R].amountLimit = 60;

        itemDetail[ALL_SEED_C].amountLimit = 1000200;
        itemDetail[ALL_SEED_UC].amountLimit = 200;
        itemDetail[ALL_SEED_R].amountLimit = 40;

        itemDetail[STAMINA_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[STAMINA_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[STAMINA_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[STRENGTH_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[STRENGTH_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[STRENGTH_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[WISDOM_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[WISDOM_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[WISDOM_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[ACCURACY_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[ACCURACY_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[ACCURACY_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[EVASION_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[EVASION_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[EVASION_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[DEFENSE_GUIDE_BOOK_C].amountLimit = 500;
        itemDetail[DEFENSE_GUIDE_BOOK_UC].amountLimit = 100;
        itemDetail[DEFENSE_GUIDE_BOOK_R].amountLimit = 20;

        itemDetail[ULTIMANIA_C].amountLimit = 300;
        itemDetail[ULTIMANIA_UC].amountLimit = 60;
        itemDetail[ULTIMANIA_R].amountLimit = 12;

        itemDetail[REFRESHING_AROMA_C].amountLimit = 500;
        itemDetail[REFRESHING_AROMA_UC].amountLimit = 100;
        itemDetail[REFRESHING_AROMA_R].amountLimit = 20;

        itemDetail[PITCHER_OF_PRAYER_C].amountLimit = 500;
        itemDetail[PITCHER_OF_PRAYER_UC].amountLimit = 100;
        itemDetail[PITCHER_OF_PRAYER_R].amountLimit = 20;

        itemDetail[INCENSE_BURNER_OF_TRANQUILITY_C].amountLimit = 500;
        itemDetail[INCENSE_BURNER_OF_TRANQUILITY_UC].amountLimit = 100;
        itemDetail[INCENSE_BURNER_OF_TRANQUILITY_R].amountLimit = 20;

        itemDetail[COMFORTABLE_INTERIOR_SET_C].amountLimit = 300;
        itemDetail[COMFORTABLE_INTERIOR_SET_UC].amountLimit = 60;
        itemDetail[COMFORTABLE_INTERIOR_SET_R].amountLimit = 12;

        itemDetail[PITCHER_OF_ANGEL_R].amountLimit = 316;

        itemDetail[PREMIUM_AROMA_R].amountLimit = 316;
    }
    // base metadata
    string public baseMetadata;

    struct ITEM_DETAIL {
        uint256 amountLimit;
        uint256 totalAmount;
    }

    uint8 public HP_SEED_C = 0;
    uint8 public HP_SEED_UC = 1;
    uint8 public HP_SEED_R = 2;
    
    uint8 public STR_SEED_C = 3;
    uint8 public STR_SEED_UC = 4;
    uint8 public STR_SEED_R = 5;
    
    uint8 public INT_SEED_C = 6;
    uint8 public INT_SEED_UC = 7;
    uint8 public INT_SEED_R = 8;

    uint8 public DEX_SEED_C = 9;
    uint8 public DEX_SEED_UC = 10;
    uint8 public DEX_SEED_R = 11;

    uint8 public AGI_SEED_C = 12;
    uint8 public AGI_SEED_UC = 13;
    uint8 public AGI_SEED_R = 14;

    uint8 public VIT_SEED_C = 15;
    uint8 public VIT_SEED_UC = 16;
    uint8 public VIT_SEED_R = 17;

    uint8 public ALL_SEED_C = 18;
    uint8 public ALL_SEED_UC = 19;
    uint8 public ALL_SEED_R = 20;

    uint8 public STAMINA_GUIDE_BOOK_C = 21;
    uint8 public STAMINA_GUIDE_BOOK_UC = 22;
    uint8 public STAMINA_GUIDE_BOOK_R = 23;

    uint8 public STRENGTH_GUIDE_BOOK_C = 24;
    uint8 public STRENGTH_GUIDE_BOOK_UC = 25;
    uint8 public STRENGTH_GUIDE_BOOK_R = 26;

    uint8 public WISDOM_GUIDE_BOOK_C = 27;
    uint8 public WISDOM_GUIDE_BOOK_UC = 28;
    uint8 public WISDOM_GUIDE_BOOK_R = 29;

    uint8 public ACCURACY_GUIDE_BOOK_C = 30;
    uint8 public ACCURACY_GUIDE_BOOK_UC = 31;
    uint8 public ACCURACY_GUIDE_BOOK_R = 32;

    uint8 public EVASION_GUIDE_BOOK_C = 33;
    uint8 public EVASION_GUIDE_BOOK_UC = 34;
    uint8 public EVASION_GUIDE_BOOK_R = 35;

    uint8 public DEFENSE_GUIDE_BOOK_C = 36;
    uint8 public DEFENSE_GUIDE_BOOK_UC = 37;
    uint8 public DEFENSE_GUIDE_BOOK_R = 38;

    uint8 public ULTIMANIA_C = 39;
    uint8 public ULTIMANIA_UC = 40;
    uint8 public ULTIMANIA_R = 41;

    uint8 public REFRESHING_AROMA_C = 42;
    uint8 public REFRESHING_AROMA_UC = 43;
    uint8 public REFRESHING_AROMA_R = 44;

    uint8 public PITCHER_OF_PRAYER_C = 45;
    uint8 public PITCHER_OF_PRAYER_UC = 46;
    uint8 public PITCHER_OF_PRAYER_R = 47;

    uint8 public INCENSE_BURNER_OF_TRANQUILITY_C = 48;
    uint8 public INCENSE_BURNER_OF_TRANQUILITY_UC = 49;
    uint8 public INCENSE_BURNER_OF_TRANQUILITY_R = 50;

    uint8 public COMFORTABLE_INTERIOR_SET_C = 51;
    uint8 public COMFORTABLE_INTERIOR_SET_UC = 52;
    uint8 public COMFORTABLE_INTERIOR_SET_R = 53;
    
    uint8 public PITCHER_OF_ANGEL_R = 54;

    uint8 public PREMIUM_AROMA_R = 55;

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    mapping(uint256 => ITEM_DETAIL) public itemDetail;
    // EVENT
    event mintEnhanceItem(
        address _addressTo,
        uint256 itemId,
        uint256 number,
        bytes data
    );

    event mintBatchEnhanceItem(
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

    // Update total amount
    function _updateTotalAmount(
        uint256[] memory _itemId,
        uint256[] memory _number
    ) internal {
        for (uint i = 0; i < _itemId.length; i++) {
            require(_itemId[i] < 56, "EnhanceItem::_updateTotalAmount: Unsupported itemId");
            uint256 remain = itemDetail[_itemId[i]].amountLimit - itemDetail[_itemId[i]].totalAmount;
            require(remain >= _number[i], "EnhanceItem::_updateTotalAmount: exceeding");
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
        require(_itemId < 56, "EnhanceItem::mint: Unsupported itemId");
        uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
        require(remain > 0, "EnhanceItem::mint: exceeding");
        _mint(_addressTo, _itemId, _number, _data);
        itemDetail[_itemId].totalAmount++;
        emit mintEnhanceItem(_addressTo, _itemId,_number, _data);
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
        emit mintBatchEnhanceItem(_addressTo, _itemId, _number, "");
    }
    
    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external onlyRole(MANAGEMENT_ROLE){
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }
}
