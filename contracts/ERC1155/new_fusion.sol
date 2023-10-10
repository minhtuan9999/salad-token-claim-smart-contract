//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract FusionItem is ERC1155, AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    using EnumerableSet for EnumerableSet.UintSet;
    using Strings for uint256;
    uint256 public currentId;
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

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 
        _initDefautItems();
    }

    // EVENT
    event mintFusionItem(
        address _addressTo,
        uint256 itemId,
        uint256 number,
        bytes data
    );
    
    event mintBatchFusionItem(
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
                require(itemDetail[ids[i]].typeItem != 4, "FusionItem::_beforeTokenTransfer: Items cannot be transferred");
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
            require(_itemId[i] < 36, "FusionItem::_updateTotalAmount: Unsupported itemId");
            uint256 remain = itemDetail[_itemId[i]].amountLimit - itemDetail[_itemId[i]].totalAmount;
            require(remain >= _number[i], "FusionItem::_updateTotalAmount: exceeding");
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
        require(_itemId < 36, "FusionItem::mint: Unsupported itemId");
        uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
        require(remain > 0, "FusionItem:: mint: exceeding");
        _mint(_addressTo, _itemId, _number, _data);
        itemDetail[_itemId].totalAmount++;
        emit mintFusionItem(_addressTo, _itemId,_number, _data);
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
        emit mintBatchFusionItem(_addressTo, _itemId, _number, "");
    }
    
    function burn(address _from, uint256 _id, uint256 _amount) external onlyRole(MANAGEMENT_ROLE) {
        _burn(_from, _id, _amount);
        emit burnItem(_from, _id, _amount);
    }
    
    function burnMultipleItem(address _from, uint256[] memory _id, uint256[] memory _amount) external onlyRole(MANAGEMENT_ROLE){
        _burnBatch(_from, _id, _amount);
        emit burnBathItem(_from, _id, _amount);
    }

    function _initDefautItems()private {
        itemDetail[0].name = "FAIRY_FEATHER_UC";
        itemDetail[0].typeItem = 2;
        itemDetail[0].amountLimit = 200;

        itemDetail[1].name = "GOLEM_CORE_UC";
        itemDetail[1].typeItem = 2;        
        itemDetail[1].amountLimit = 200;

        itemDetail[2].name = "YUBA_UC";
        itemDetail[2].typeItem = 2;
        itemDetail[2].amountLimit = 200;

        itemDetail[3].name = "UNICORN_HORN_UC";
        itemDetail[3].typeItem = 2;
        itemDetail[3].amountLimit = 200;

        itemDetail[4].name = "RED_JEWEL_UC";
        itemDetail[4].typeItem = 2;
        itemDetail[4].amountLimit = 200;

        itemDetail[5].name = "CAT_WHISKER_UC";
        itemDetail[5].typeItem = 2;
        itemDetail[5].amountLimit = 200;

        itemDetail[6].name = "WITCHS_WAND_UC";
        itemDetail[6].typeItem = 2;
        itemDetail[6].amountLimit = 200;

        itemDetail[7].name = "IMP_TAIL_UC";
        itemDetail[7].typeItem = 2;
        itemDetail[7].amountLimit = 200;

        itemDetail[8].name = "ODEN_UC";
        itemDetail[8].typeItem = 2;
        itemDetail[8].amountLimit = 200;

        itemDetail[9].name = "AQUATIC_EGG_UC";
        itemDetail[9].typeItem = 2;
        itemDetail[9].amountLimit = 200;

        itemDetail[10].name = "WAFUKU_UC";
        itemDetail[10].typeItem = 2;
        itemDetail[10].amountLimit = 200;

        itemDetail[11].name = "SCHOOL_UNIFORM_UC";
        itemDetail[11].typeItem = 2;
        itemDetail[11].amountLimit = 200;
        
        itemDetail[12].name = "MOFUMOFU_UC";
        itemDetail[12].typeItem = 2;
        itemDetail[12].amountLimit = 200;

        itemDetail[13].name = "MAAT_UC";
        itemDetail[13].typeItem = 2;
        itemDetail[13].amountLimit = 200;

        itemDetail[14].name = "INDESTRUCTIBLE_ICE_UC";
        itemDetail[14].typeItem = 2;
        itemDetail[14].amountLimit = 200;

        itemDetail[15].name = "KAWAII_CANDY_UC";
        itemDetail[15].typeItem = 2;
        itemDetail[15].amountLimit = 200;

        itemDetail[16].name = "DETERMINATION_OF_JUSTICE_UC";
        itemDetail[16].typeItem = 2;
        itemDetail[16].amountLimit = 200;

        itemDetail[17].name = "KNOWLEDGE_OF_MALICE_UC";
        itemDetail[17].typeItem = 2;
        itemDetail[17].amountLimit = 200;

        itemDetail[18].name = "SAKE_BARREL_UC";
        itemDetail[18].typeItem = 2;
        itemDetail[18].amountLimit = 200;

        itemDetail[19].name = "MECHANICAL_BLADE_UC";
        itemDetail[19].typeItem = 2;
        itemDetail[19].amountLimit = 200;
        
        itemDetail[20].name = "BELLYBAND_UC";
        itemDetail[20].typeItem = 2;
        itemDetail[20].amountLimit = 200;
        
        itemDetail[21].name = "SECRET_DATA_C";
        itemDetail[21].typeItem = 1;
        itemDetail[21].amountLimit = 500;

        itemDetail[22].name = "SECRET_DATA_UC";
        itemDetail[22].typeItem = 2;
        itemDetail[22].amountLimit = 100;

        itemDetail[23].name = "SECRET_DATA_R";
        itemDetail[23].typeItem = 3;
        itemDetail[23].amountLimit = 20;

        itemDetail[24].name = "BOOST_CHIP_STRENGTH_C";
        itemDetail[24].typeItem = 1;
        itemDetail[24].amountLimit = 300;

        itemDetail[25].name = "BOOST_CHIP_STRENGTH_UC";
        itemDetail[25].typeItem = 2;
        itemDetail[25].amountLimit = 150;

        itemDetail[26].name = "BOOST_CHIP_STRENGTH_R";
        itemDetail[26].typeItem = 3;
        itemDetail[26].amountLimit = 75;
        
        itemDetail[27].name = "BOOST_CHIP_INSIGHT_C";
        itemDetail[27].typeItem = 1;
        itemDetail[27].amountLimit = 300;

        itemDetail[28].name = "BOOST_CHIP_INSIGHT_UC";
        itemDetail[28].typeItem = 2;
        itemDetail[28].amountLimit = 150;

        itemDetail[29].name = "BOOST_CHIP_INSIGHT_R";
        itemDetail[29].typeItem = 3;
        itemDetail[29].amountLimit = 75;

        itemDetail[30].name = "BOOST_CHIP_PRECISION_C";
        itemDetail[30].typeItem = 1;
        itemDetail[30].amountLimit = 300;

        itemDetail[31].name = "BOOST_CHIP_PRECISION_UC";
        itemDetail[31].typeItem = 2;
        itemDetail[31].amountLimit = 150;

        itemDetail[32].name = "BOOST_CHIP_PRECISION_R";
        itemDetail[32].typeItem = 3;
        itemDetail[32].amountLimit = 75;

        itemDetail[33].name = "BOOST_CHIP_SOLID_C";
        itemDetail[33].typeItem = 1;
        itemDetail[33].amountLimit = 300;

        itemDetail[34].name = "BOOST_CHIP_SOLID_UC";
        itemDetail[34].typeItem = 2;
        itemDetail[34].amountLimit = 150;

        itemDetail[35].name = "BOOST_CHIP_SOLID_R";
        itemDetail[35].typeItem = 3;
        itemDetail[35].amountLimit = 75;

        itemDetail[36].name = "SECRET_DATA_B";
        itemDetail[36].typeItem = 4;

        itemDetail[37].name = "BOOST_CHIP_B";
        itemDetail[37].typeItem = 4;

        itemDetail[38].name = "FAIRY_FEATHER_B";
        itemDetail[38].typeItem = 4;

        itemDetail[39].name = "GOLEM_CORE_B";
        itemDetail[39].typeItem = 4;

        itemDetail[40].name = "YUBA_B";
        itemDetail[40].typeItem = 4;

        itemDetail[41].name = "UNICORN_HORN_B";
        itemDetail[41].typeItem = 4;

        itemDetail[42].name = "RED_JEWEL_B";
        itemDetail[42].typeItem = 4;

        itemDetail[43].name = "CAT_WHISKER_B";
        itemDetail[43].typeItem = 4;

        itemDetail[44].name = "WITCHS_WAND_B";
        itemDetail[44].typeItem = 4;

        itemDetail[45].name = "IMP_TAIL_B";
        itemDetail[45].typeItem = 4;

        itemDetail[46].name = "ODEN_B";
        itemDetail[46].typeItem = 4;

        itemDetail[47].name = "AQUATIC_EGG_B";
        itemDetail[47].typeItem = 4;

        itemDetail[48].name = "WAFUKU_B";
        itemDetail[48].typeItem = 4;

        itemDetail[49].name = "SCHOOL_UNIFORM_B";
        itemDetail[49].typeItem = 4;

        itemDetail[50].name = "MOFUMOFU_B";
        itemDetail[50].typeItem = 4;

        itemDetail[51].name = "MAAT_B";
        itemDetail[51].typeItem = 4;

        itemDetail[52].name = "INDESTRUCTIBLE_ICE_B";
        itemDetail[52].typeItem = 4;

        itemDetail[53].name = "KAWAII_CANDY_B";
        itemDetail[53].typeItem = 4;

        itemDetail[54].name = "DETERMINATION_OF_JUSTICE_B";
        itemDetail[54].typeItem = 4;

        itemDetail[55].name = "KNOWLEDGE_OF_MALICE_B";
        itemDetail[55].typeItem = 4;

        itemDetail[56].name = "SAKE_BARREL_B";
        itemDetail[56].typeItem = 4;

        itemDetail[57].name = "MECHANICAL_BLADE_B";
        itemDetail[57].typeItem = 4;

        itemDetail[58].name = "BELLYBAND_B";
        itemDetail[58].typeItem = 4;

        currentId = 59;
    }
}
