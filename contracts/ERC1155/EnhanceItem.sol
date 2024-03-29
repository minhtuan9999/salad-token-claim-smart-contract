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
                require(itemDetail[ids[i]].typeItem != 4, "EhanceItem::_beforeTokenTransfer: Items cannot be transferred");
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
                "EnhanceItem::_updateTotalAmount: Unsupported itemId"
            );
            if(itemDetail[_itemId[i]].typeItem != 0 && itemDetail[_itemId[i]].amountLimit == 0) continue;
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
        if (itemDetail[_itemId].typeItem != 0 && itemDetail[_itemId].amountLimit == 0) {
            _mint(_addressTo, _itemId, _number, _data);
        } else {
            uint256 remain = itemDetail[_itemId].amountLimit -
                itemDetail[_itemId].totalAmount;
            require(remain >= _number, "TrainingItem:: mint: exceeding");
            _mint(_addressTo, _itemId, _number, _data);
            itemDetail[_itemId].totalAmount++;
        }
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

    // burn items
    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    // burn multiple items
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external onlyRole(MANAGEMENT_ROLE){
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }

    function _initDefautItems() private {
        itemDetail[0].name = "HP_SEED_C";
        itemDetail[0].typeItem = 1;
        itemDetail[0].amountLimit = 1500;

        itemDetail[1].name = "HP_SEED_UC";
        itemDetail[1].typeItem = 2;
        itemDetail[1].amountLimit = 300;

        itemDetail[2].name = "HP_SEED_R";
        itemDetail[2].typeItem = 3;
        itemDetail[2].amountLimit = 60;
        
        itemDetail[3].name = "STR_SEED_C";
        itemDetail[3].typeItem = 1;
        itemDetail[3].amountLimit = 1500;

        itemDetail[4].name = "STR_SEED_UC";
        itemDetail[4].typeItem = 2;
        itemDetail[4].amountLimit = 300;

        itemDetail[5].name = "STR_SEED_R";
        itemDetail[5].typeItem = 3;
        itemDetail[5].amountLimit = 60;

        itemDetail[6].name = "INT_SEED_C";
        itemDetail[6].typeItem = 1;
        itemDetail[6].amountLimit = 1500;

        itemDetail[7].name = "INT_SEED_UC";
        itemDetail[7].typeItem = 2;
        itemDetail[7].amountLimit = 300;

        itemDetail[8].name = "INT_SEED_R";
        itemDetail[8].typeItem = 3;
        itemDetail[8].amountLimit = 60;

        itemDetail[9].name = "DEX_SEED_C";
        itemDetail[9].typeItem = 1;
        itemDetail[9].amountLimit = 1500;

        itemDetail[10].name = "DEX_SEED_UC";
        itemDetail[10].typeItem = 2;
        itemDetail[10].amountLimit = 300;

        itemDetail[11].name = "DEX_SEED_R";
        itemDetail[11].typeItem = 3;
        itemDetail[11].amountLimit = 60;

        itemDetail[12].name = "AGI_SEED_C";
        itemDetail[12].typeItem = 1;
        itemDetail[12].amountLimit = 1500;

        itemDetail[13].name = "AGI_SEED_UC";
        itemDetail[13].typeItem = 2;
        itemDetail[13].amountLimit = 300;

        itemDetail[14].name = "AGI_SEED_R";
        itemDetail[14].typeItem = 3;
        itemDetail[14].amountLimit = 60;

        itemDetail[15].name = "VIT_SEED_C";
        itemDetail[15].typeItem = 1;
        itemDetail[15].amountLimit = 1500;

        itemDetail[16].name = "VIT_SEED_UC";
        itemDetail[16].typeItem = 2;
        itemDetail[16].amountLimit = 300;

        itemDetail[17].name = "VIT_SEED_R";
        itemDetail[17].typeItem = 3;
        itemDetail[17].amountLimit = 60;

        itemDetail[18].name = "ALL_SEED_C";
        itemDetail[18].typeItem = 1;
        itemDetail[18].amountLimit = 1000;

        itemDetail[19].name = "ALL_SEED_UC";
        itemDetail[19].typeItem = 2;
        itemDetail[19].amountLimit = 200;

        itemDetail[20].name = "ALL_SEED_R";
        itemDetail[20].typeItem = 3;
        itemDetail[20].amountLimit = 40;

        itemDetail[21].name = "STAMINA_GUIDE_BOOK_C";
        itemDetail[21].typeItem = 1;
        itemDetail[21].amountLimit = 500;

        itemDetail[22].name = "STAMINA_GUIDE_BOOK_UC";
        itemDetail[22].typeItem = 2;
        itemDetail[22].amountLimit = 100;

        itemDetail[23].name = "STAMINA_GUIDE_BOOK_R";
        itemDetail[23].typeItem = 3;
        itemDetail[23].amountLimit = 20;

        itemDetail[24].name = "STRENGTH_GUIDE_BOOK_C";
        itemDetail[24].typeItem = 1;
        itemDetail[24].amountLimit = 500;

        itemDetail[25].name = "STRENGTH_GUIDE_BOOK_UC";
        itemDetail[25].typeItem = 2;
        itemDetail[25].amountLimit = 100;

        itemDetail[26].name = "STRENGTH_GUIDE_BOOK_R";
        itemDetail[26].typeItem = 3;
        itemDetail[26].amountLimit = 20;

        itemDetail[27].name = "WISDOM_GUIDE_BOOK_C";
        itemDetail[27].typeItem = 1;
        itemDetail[27].amountLimit = 500;

        itemDetail[28].name = "WISDOM_GUIDE_BOOK_UC";
        itemDetail[28].typeItem = 2;
        itemDetail[28].amountLimit = 100;

        itemDetail[29].name = "WISDOM_GUIDE_BOOK_R";
        itemDetail[29].typeItem = 3;
        itemDetail[29].amountLimit = 20;

        itemDetail[30].name = "ACCURACY_GUIDE_BOOK_C";
        itemDetail[30].typeItem = 1;
        itemDetail[30].amountLimit = 500;

        itemDetail[31].name = "ACCURACY_GUIDE_BOOK_UC";
        itemDetail[31].typeItem = 2;
        itemDetail[31].amountLimit = 100;

        itemDetail[32].name = "ACCURACY_GUIDE_BOOK_R";
        itemDetail[32].typeItem = 3;
        itemDetail[32].amountLimit = 20;

        itemDetail[33].name = "AVOIDANCE_GUIDE_BOOK_C";
        itemDetail[33].typeItem = 1;
        itemDetail[33].amountLimit = 500;

        itemDetail[34].name = "AVOIDANCE_GUIDE_BOOK_UC";
        itemDetail[34].typeItem = 2;
        itemDetail[34].amountLimit = 100;

        itemDetail[35].name = "AVOIDANCE_GUIDE_BOOK_R";
        itemDetail[35].typeItem = 3;
        itemDetail[35].amountLimit = 20;

        itemDetail[36].name = "DEFENSE_GUIDE_BOOK_C";
        itemDetail[36].typeItem = 1;
        itemDetail[36].amountLimit = 500;

        itemDetail[37].name = "DEFENSE_GUIDE_BOOK_UC";
        itemDetail[37].typeItem = 2;
        itemDetail[37].amountLimit = 100;

        itemDetail[38].name = "DEFENSE_GUIDE_BOOK_R";
        itemDetail[38].typeItem = 3;
        itemDetail[38].amountLimit = 20;

        itemDetail[39].name = "ULTIMANIA_C";
        itemDetail[39].typeItem = 1;
        itemDetail[39].amountLimit = 500;

        itemDetail[40].name = "ULTIMANIA_UC";
        itemDetail[40].typeItem = 2;
        itemDetail[40].amountLimit = 100;

        itemDetail[41].name = "ULTIMANIA_R";
        itemDetail[41].typeItem = 3;
        itemDetail[41].amountLimit = 20;

        itemDetail[42].name = "REFRESHING_AROMA_C";
        itemDetail[42].typeItem = 1;
        itemDetail[42].amountLimit = 500;

        itemDetail[43].name = "REFRESHING_AROMA_UC";
        itemDetail[43].typeItem = 2;
        itemDetail[43].amountLimit = 100;

        itemDetail[44].name = "REFRESHING_AROMA_R";
        itemDetail[44].typeItem = 3;
        itemDetail[44].amountLimit = 20;

        itemDetail[45].name = "PITCHER_OF_PRAYER_C";
        itemDetail[45].typeItem = 1;
        itemDetail[45].amountLimit = 500;

        itemDetail[46].name = "PITCHER_OF_PRAYER_UC";
        itemDetail[46].typeItem = 2;
        itemDetail[46].amountLimit = 100;

        itemDetail[47].name = "PITCHER_OF_PRAYER_R";
        itemDetail[47].typeItem = 3;
        itemDetail[47].amountLimit = 20;

        itemDetail[48].name = "INCENSE_BURNER_OF_TRANQUILITY_C";
        itemDetail[48].typeItem = 1;
        itemDetail[48].amountLimit = 500;

        itemDetail[49].name = "INCENSE_BURNER_OF_TRANQUILITY_UC";
        itemDetail[49].typeItem = 2;
        itemDetail[49].amountLimit = 100;

        itemDetail[50].name = "INCENSE_BURNER_OF_TRANQUILITY_R";
        itemDetail[50].typeItem = 3;
        itemDetail[50].amountLimit = 20;

        itemDetail[51].name = "COMFORTABLE_INTERIOR_SET_C";
        itemDetail[51].typeItem = 1;
        itemDetail[51].amountLimit = 300;

        itemDetail[52].name = "COMFORTABLE_INTERIOR_SET_UC";
        itemDetail[52].typeItem = 2;
        itemDetail[52].amountLimit = 60;

        itemDetail[53].name = "COMFORTABLE_INTERIOR_SET_R";
        itemDetail[53].typeItem = 3;
        itemDetail[53].amountLimit = 12;

        itemDetail[54].name = "PITCHER_OF_ANGEL_R";
        itemDetail[54].typeItem = 3;
        itemDetail[54].amountLimit = 316;

        itemDetail[55].name = "PREMIUM_AROMA_R";
        itemDetail[55].typeItem = 3;
        itemDetail[55].amountLimit = 316;

        itemDetail[56].name = "ALL_SEED_B";
        itemDetail[56].typeItem = 4;

        itemDetail[57].name = "GUIDE_BOOK_B";
        itemDetail[57].typeItem = 4;

        itemDetail[58].name = "PITCHER_OF_PRAYER_B";
        itemDetail[58].typeItem = 4;

        itemDetail[59].name = "INCENSE_BURNER_OF_TRANQUILITY_B";
        itemDetail[59].typeItem = 4;  
        
        itemDetail[60].name = "CRYSTAL_OF_OO_R";
        itemDetail[60].typeItem = 3;  
        
        itemDetail[61].name = "HP_COACH_R";
        itemDetail[61].typeItem = 3;

        itemDetail[62].name = "STR_COACH_R";
        itemDetail[62].typeItem = 3;

        itemDetail[63].name = "INT_COACH_R";
        itemDetail[63].typeItem = 3;

        itemDetail[64].name = "DEX_COACH_R";
        itemDetail[64].typeItem = 3;

        itemDetail[65].name = "AGI_COACH_R";
        itemDetail[65].typeItem = 3;

        itemDetail[66].name = "VIT_COACH_R";
        itemDetail[66].typeItem = 3;

        currentId = 67;
    }

}
