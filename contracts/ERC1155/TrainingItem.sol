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

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 

        itemDetail[ENERGY_BANANA_C].amountLimit = 5000;
        itemDetail[ENERGY_BANANA_UC].amountLimit = 1000;
        itemDetail[ENERGY_BANANA_R].amountLimit = 200;

        itemDetail[REFRESH_HERB_C].amountLimit = 5000;
        itemDetail[REFRESH_HERB_UC].amountLimit = 1000;
        itemDetail[REFRESH_HERB_R].amountLimit = 200;
        
        itemDetail[FRESH_MILK_C].amountLimit = 5000;
        itemDetail[FRESH_MILK_UC].amountLimit = 1000;
        itemDetail[FRESH_MILK_R].amountLimit = 200;

        itemDetail[FAIRY_BERRY_C].amountLimit = 5000;
        itemDetail[FAIRY_BERRY_UC].amountLimit = 1000;
        itemDetail[FAIRY_BERRY_R].amountLimit = 200;

        itemDetail[CARAMEL_CAKE_C].amountLimit = 5000;
        itemDetail[CARAMEL_CAKE_UC].amountLimit = 1000;
        itemDetail[CARAMEL_CAKE_R].amountLimit = 200;

        itemDetail[CHIA_YOGURT_C].amountLimit = 5000;
        itemDetail[CHIA_YOGURT_UC].amountLimit = 1000;
        itemDetail[CHIA_YOGURT_R].amountLimit = 200;

        itemDetail[SATIETY_KONJACT_C].amountLimit = 5000;
        itemDetail[SATIETY_KONJACT_UC].amountLimit = 1000;
        itemDetail[SATIETY_KONJACT_R].amountLimit = 200;

        itemDetail[GLORIOUS_MEAT_C].amountLimit = 5000;
        itemDetail[GLORIOUS_MEAT_UC].amountLimit = 1000;
        itemDetail[GLORIOUS_MEAT_R].amountLimit = 200;

        itemDetail[SUNNY_BLOSSOM_C].amountLimit = 5000;
        itemDetail[SUNNY_BLOSSOM_UC].amountLimit = 1000;
        itemDetail[SUNNY_BLOSSOM_R].amountLimit = 200;

        itemDetail[LUNAR_GRASS_C].amountLimit = 5000;
        itemDetail[LUNAR_GRASS_UC].amountLimit = 1000;
        itemDetail[LUNAR_GRASS_R].amountLimit = 200;

        itemDetail[LIFE_WATER_C].amountLimit = 500;
        itemDetail[LIFE_WATER_UC].amountLimit = 200;
        itemDetail[LIFE_WATER_R].amountLimit = 50;

    }
    // base metadata
    string public baseMetadata;

    struct ITEM_DETAIL {
        uint256 amountLimit;
        uint256 totalAmount;
    }

    uint8 public ENERGY_BANANA_C  = 0;
    uint8 public ENERGY_BANANA_UC  = 1;
    uint8 public ENERGY_BANANA_R  = 2;
    uint8 public ENERGY_BANANA_SHOP  = 3;

    uint8 public REFRESH_HERB_C  = 4;
    uint8 public REFRESH_HERB_UC  = 5;
    uint8 public REFRESH_HERB_R  = 6;
    uint8 public REFRESH_HERB_SHOP  = 7;

    uint8 public FRESH_MILK_C  = 8;
    uint8 public FRESH_MILK_UC  = 9;
    uint8 public FRESH_MILK_R  = 10;
    uint8 public FRESH_MILK_SHOP  = 11;

    uint8 public FAIRY_BERRY_C  = 12;
    uint8 public FAIRY_BERRY_UC  = 13;
    uint8 public FAIRY_BERRY_R  = 14;
    uint8 public FAIRY_BERRY_SHOP  = 15;

    uint8 public CARAMEL_CAKE_C  = 16;
    uint8 public CARAMEL_CAKE_UC  = 17;
    uint8 public CARAMEL_CAKE_R  = 18;
    uint8 public CARAMEL_CAKE_SHOP  = 19;

    uint8 public CHIA_YOGURT_C  = 20;
    uint8 public CHIA_YOGURT_UC  = 21;
    uint8 public CHIA_YOGURT_R  = 22;
    uint8 public CHIA_YOGURT_SHOP  = 23;

    uint8 public SATIETY_KONJACT_C  = 24;
    uint8 public SATIETY_KONJACT_UC  = 25;
    uint8 public SATIETY_KONJACT_R  = 26;
    uint8 public SATIETY_KONJACT_SHOP  = 27;

    uint8 public GLORIOUS_MEAT_C  = 28;
    uint8 public GLORIOUS_MEAT_UC  = 29;
    uint8 public GLORIOUS_MEAT_R  = 30;
    uint8 public GLORIOUS_MEAT_SHOP  = 31;

    uint8 public SUNNY_BLOSSOM_C  = 32;
    uint8 public SUNNY_BLOSSOM_UC  = 33;
    uint8 public SUNNY_BLOSSOM_R  = 34;
    uint8 public SUNNY_BLOSSOM_SHOP  = 35;

    uint8 public LUNAR_GRASS_C  = 36;
    uint8 public LUNAR_GRASS_UC  = 37;
    uint8 public LUNAR_GRASS_R  = 38;
    uint8 public LUNAR_GRASS_SHOP  = 39;

    uint8 public LIFE_WATER_C  = 40;
    uint8 public LIFE_WATER_UC  = 41;
    uint8 public LIFE_WATER_R  = 42;

    uint8 public TOUNAMENT_TICKET_UC  = 43;

    uint8 public EXPLORATION_TICKET_UC  = 44;

    uint8 public FLOWER_CROWN_C  = 45;

    uint8 public DEKAUSA_DOLL_C  = 46;

    uint8 public SILK_HANDKERCHIEF_C  = 47;

    uint8 public NUTS_C  = 48;

    uint8 public PRETTY_STONE_C  = 49;

    uint8 public SILVER_INGOT_UC  = 50;

    uint8 public GOLD_INGOT_UC  = 51;

    uint8 public GEM_BAG_R  = 52;

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
        if(_isUnlimited(_itemId)) {
            _mint(_addressTo, _itemId, _number, _data);
        }else{
            uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
            require(remain > 0, "RegenerationItem:: mint: exceeding");
            _mint(_addressTo, _itemId, _number, _data);
            itemDetail[_itemId].totalAmount++;
        }
        emit mintTrainingItem(_addressTo, _itemId,_number, _data);
    }
    
    function isOnlyShop(uint256 _itemId) external view returns(bool) {
        return _itemId == ENERGY_BANANA_SHOP||
            _itemId == REFRESH_HERB_SHOP||
            _itemId == FRESH_MILK_SHOP||
            _itemId == FAIRY_BERRY_SHOP||
            _itemId == CARAMEL_CAKE_SHOP||
            _itemId == CHIA_YOGURT_SHOP||
            _itemId == SATIETY_KONJACT_SHOP||
            _itemId == GLORIOUS_MEAT_SHOP||
            _itemId == SUNNY_BLOSSOM_SHOP||
            _itemId == LUNAR_GRASS_SHOP;
    }

    function _isUnlimited(uint256 _itemId) private view returns(bool) {
        return _itemId == ENERGY_BANANA_SHOP||
            _itemId == REFRESH_HERB_SHOP||
            _itemId == FRESH_MILK_SHOP||
            _itemId == FAIRY_BERRY_SHOP||
            _itemId == CARAMEL_CAKE_SHOP||
            _itemId == CHIA_YOGURT_SHOP||
            _itemId == SATIETY_KONJACT_SHOP||
            _itemId == GLORIOUS_MEAT_SHOP||
            _itemId == SUNNY_BLOSSOM_SHOP||
            _itemId == LUNAR_GRASS_SHOP||
            _itemId == TOUNAMENT_TICKET_UC||
            _itemId == EXPLORATION_TICKET_UC||
            _itemId == FLOWER_CROWN_C||
            _itemId == DEKAUSA_DOLL_C||
            _itemId == SILK_HANDKERCHIEF_C||
            _itemId == NUTS_C||
            _itemId == PRETTY_STONE_C||
            _itemId == SILVER_INGOT_UC||
            _itemId == GOLD_INGOT_UC||
            _itemId == GEM_BAG_R ;
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
