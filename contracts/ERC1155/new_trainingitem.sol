//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TrainingItem is ERC1155, AccessControl, Ownable {
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
    event mintTrainingItem(
        address _addressTo,
        uint256 itemId,
        uint256 number,
        bytes data
    );
    event mintBatchTrainingItem(
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
        for (uint256 i = 0; i < ids.length; i++) {
            if (from != address(0)) {
                require(itemDetail[ids[i]].typeItem != 4, "TrainingItem::_beforeTokenTransfer: Items cannot be transferred");
                if ((balanceOf(from, ids[i]) - amounts[i]) == 0) {
                    _listTokensOfAddress[from].remove(ids[i]);
                }
            }
            if (to != address(0)) {
                _listTokensOfAddress[to].add(ids[i]);
            }
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // get list item of address
    function getListItemOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    /**
     * 
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
        emit mintTrainingItem(_addressTo, _itemId, _number, _data);
    }

    // Update total amount
    function _updateTotalAmount(
        uint256[] memory _itemId,
        uint256[] memory _number
    ) internal {
        for (uint i = 0; i < _itemId.length; i++) {
            require(
                itemDetail[_itemId[i]].typeItem != 0,
                "TrainingItem::_updateTotalAmount: Unsupported itemId"
            );
            if (itemDetail[_itemId[i]].typeItem != 0 && itemDetail[_itemId[i]].amountLimit == 0) continue;
            uint256 remain = itemDetail[_itemId[i]].amountLimit -
                itemDetail[_itemId[i]].totalAmount;
            require(
                remain >= _number[i],
                "TrainingItem::_updateTotalAmount: exceeding"
            );
            itemDetail[_itemId[i]].totalAmount =
                itemDetail[_itemId[i]].totalAmount +
                _number[i];
        }
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
        emit mintBatchTrainingItem(_addressTo, _itemId, _number, "");
    }

    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external onlyRole(MANAGEMENT_ROLE) {
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }

    // init defaut items C:1, UC:2, R:3, B:4 (shop/bonus)
    function _initDefautItems() private {
        itemDetail[0].name = "ENERGY_BANANA_C";
        itemDetail[0].typeItem = 1;
        itemDetail[0].amountLimit = 5000;
        itemDetail[1].name = "ENERGY_BANANA_UC";
        itemDetail[1].typeItem = 2;
        itemDetail[1].amountLimit = 1000;
        itemDetail[2].name = "ENERGY_BANANA_R";
        itemDetail[2].typeItem = 3;
        itemDetail[2].amountLimit = 200;
        itemDetail[3].name = "ENERGY_BANANA_SHOP";
        itemDetail[3].typeItem = 4;

        itemDetail[4].name = "REFRESH_HERB_C";
        itemDetail[4].typeItem = 1;
        itemDetail[4].amountLimit = 5000;
        itemDetail[5].name = "REFRESH_HERB_UC";
        itemDetail[5].typeItem = 2;
        itemDetail[5].amountLimit = 1000;
        itemDetail[6].name = "REFRESH_HERB_R";
        itemDetail[6].typeItem = 3;
        itemDetail[6].amountLimit = 200;
        itemDetail[7].name = "REFRESH_HERB_SHOP";
        itemDetail[7].typeItem = 4;

        itemDetail[8].name = "FRESH_MILK_C";
        itemDetail[8].typeItem = 1;
        itemDetail[8].amountLimit = 5000;
        itemDetail[9].name = "FRESH_MILK_UC";
        itemDetail[9].typeItem = 2;
        itemDetail[9].amountLimit = 1000;
        itemDetail[10].name = "FRESH_MILK_R";
        itemDetail[10].typeItem = 3;
        itemDetail[10].amountLimit = 200;
        itemDetail[11].name = "FRESH_MILK_SHOP";
        itemDetail[11].typeItem = 4;

        itemDetail[12].name = "FAIRY_BERRY_C";
        itemDetail[12].typeItem = 1;
        itemDetail[12].amountLimit = 5000;
        itemDetail[13].name = "FAIRY_BERRY_UC";
        itemDetail[13].typeItem = 2;
        itemDetail[13].amountLimit = 1000;
        itemDetail[14].name = "FAIRY_BERRY_R";
        itemDetail[14].typeItem = 3;
        itemDetail[14].amountLimit = 200;
        itemDetail[15].name = "FAIRY_BERRY_SHOP";
        itemDetail[15].typeItem = 4;

        itemDetail[16].name = "CARAMEL_CAKE_C";
        itemDetail[16].typeItem = 1;
        itemDetail[16].amountLimit = 5000;
        itemDetail[17].name = "CARAMEL_CAKE_UC";
        itemDetail[17].typeItem = 2;
        itemDetail[17].amountLimit = 1000;
        itemDetail[18].name = "CARAMEL_CAKE_R";
        itemDetail[18].typeItem = 3;
        itemDetail[18].amountLimit = 200;
        itemDetail[19].name = "CARAMEL_CAKE_SHOP";
        itemDetail[19].typeItem = 4;

        itemDetail[20].name = "CHIA_YOGURT_C";
        itemDetail[20].typeItem = 1;
        itemDetail[20].amountLimit = 5000;
        itemDetail[21].name = "CHIA_YOGURT_UC";
        itemDetail[21].typeItem = 2;
        itemDetail[21].amountLimit = 1000;
        itemDetail[22].name = "CHIA_YOGURT_R";
        itemDetail[22].typeItem = 3;
        itemDetail[22].amountLimit = 200;
        itemDetail[23].name = "CHIA_YOGURT_SHOP";
        itemDetail[23].typeItem = 4;

        itemDetail[24].name = "SATIETY_KONJACT_C";
        itemDetail[24].typeItem = 1;
        itemDetail[24].amountLimit = 5000;
        itemDetail[25].name = "SATIETY_KONJACT_UC";
        itemDetail[25].typeItem = 2;
        itemDetail[25].amountLimit = 1000;
        itemDetail[26].name = "SATIETY_KONJACT_R";
        itemDetail[26].typeItem = 3;
        itemDetail[26].amountLimit = 200;
        itemDetail[27].name = "SATIETY_KONJACT_SHOP";
        itemDetail[27].typeItem = 4;

        itemDetail[28].name = "GLORIOUS_MEAT_C";
        itemDetail[28].typeItem = 1;
        itemDetail[28].amountLimit = 5000;
        itemDetail[29].name = "GLORIOUS_MEAT_UC";
        itemDetail[29].typeItem = 2;
        itemDetail[29].amountLimit = 1000;
        itemDetail[30].name = "GLORIOUS_MEAT_R";
        itemDetail[30].typeItem = 3;
        itemDetail[30].amountLimit = 200;
        itemDetail[31].name = "GLORIOUS_MEAT_SHOP";
        itemDetail[31].typeItem = 4;

        itemDetail[32].name = "SUNNY_BLOSSOM_C";
        itemDetail[32].typeItem = 1;
        itemDetail[32].amountLimit = 5000;
        itemDetail[33].name = "SUNNY_BLOSSOM_UC";
        itemDetail[33].typeItem = 2;
        itemDetail[33].amountLimit = 1000;
        itemDetail[34].name = "SUNNY_BLOSSOM_R";
        itemDetail[34].typeItem = 3;
        itemDetail[34].amountLimit = 200;
        itemDetail[35].name = "SUNNY_BLOSSOM_SHOP";
        itemDetail[35].typeItem = 4;

        itemDetail[36].name = "LUNAR_GRASS_C";
        itemDetail[36].typeItem = 1;
        itemDetail[36].amountLimit = 5000;
        itemDetail[37].name = "LUNAR_GRASS_UC";
        itemDetail[37].typeItem = 2;
        itemDetail[37].amountLimit = 1000;
        itemDetail[38].name = "LUNAR_GRASS_R";
        itemDetail[38].typeItem = 3;
        itemDetail[38].amountLimit = 200;
        itemDetail[39].name = "LUNAR_GRASS_SHOP";
        itemDetail[39].typeItem = 4;

        itemDetail[40].name = "LIFE_WATER_C";
        itemDetail[40].typeItem = 1;
        itemDetail[40].amountLimit = 500;
        itemDetail[41].name = "LIFE_WATER_UC";
        itemDetail[41].typeItem = 2;
        itemDetail[41].amountLimit = 200;
        itemDetail[42].name = "LIFE_WATER_R";
        itemDetail[42].typeItem = 3;
        itemDetail[42].amountLimit = 50;
        
        itemDetail[43].name = "TOURNAMENT_TICKET_UC";
        itemDetail[43].typeItem = 2;
        
        itemDetail[44].name = "EXPLORATION_TICKET_UC";
        itemDetail[44].typeItem = 2;

        itemDetail[45].name = "FLOWER_CROWN_C";
        itemDetail[45].typeItem = 1;

        itemDetail[46].name = "DEKAUSA_DOLL_C";
        itemDetail[46].typeItem = 1;

        itemDetail[47].name = "SILK_HANDKERCHIEF_C";
        itemDetail[47].typeItem = 1;

        itemDetail[48].name = "NUTS_C";
        itemDetail[48].typeItem = 1;

        itemDetail[49].name = "PRETTY_STONE_C";
        itemDetail[49].typeItem = 1;

        itemDetail[50].name = "SILVER_INGOT_UC";
        itemDetail[50].typeItem = 2;

        itemDetail[51].name = "GOLD_INGOT_UC";
        itemDetail[51].typeItem = 2;

        itemDetail[52].name = "GEM_BAG_R";
        itemDetail[52].typeItem = 3;

        itemDetail[53].name = "TOURNAMENT_TICKET_B";
        itemDetail[53].typeItem = 4;

        itemDetail[54].name = "EXPLORATION_TICKET_B";
        itemDetail[54].typeItem = 4;

        currentId = 55;
    }

}
