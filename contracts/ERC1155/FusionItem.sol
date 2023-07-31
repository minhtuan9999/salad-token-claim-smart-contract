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
    // base metadata
    string public baseMetadata;

    struct ITEM_DETAIL {
        uint256 amountLimit;
        uint256 totalAmount;
    }

    uint8 public FAIRY_FEATHER_UC = 0;
    uint8 public GOLEM_CORE_UC = 1;
    uint8 public YUBA = 2;
    uint8 public UNICORN_HORN_UC = 3;
    uint8 public RED_JEWEL_UC = 4;
    uint8 public CAT_WHISKER_UC = 5;
    uint8 public WITCHS_WAND_UC = 6;
    uint8 public IMP_TAIL_UC = 7;
    uint8 public ODEN_UC = 8;
    uint8 public AQUATIC_EGG_UC = 9;
    uint8 public WAFUKU_UC = 10;
    uint8 public SCHOOL_UNIFORM_UC = 11;
    uint8 public MOFUMOFU_UC = 12;
    uint8 public MAAT_UC = 13;
    uint8 public INDESTRUCTIBLE_ICE_UC = 14;
    uint8 public KAWAII_CANDY_UC = 15;
    uint8 public DETERMINATION_OF_JUSTICE_UC = 16;
    uint8 public KNOWLEDGE_OF_MALICE_UC = 17;
    uint8 public SAKE_BARREL_UC = 18;
    uint8 public MECHANICAL_BLADE_UC = 19;
    uint8 public BELLYBAND_UC = 20;

    uint8 public SECRET_DATA_C= 21;
    uint8 public SECRET_DATA_UC = 22;
    uint8 public SECRET_DATA_R = 23;

    uint8 public BOOST_CHIP_STRENGTH_C = 24;
    uint8 public BOOST_CHIP_STRENGTH_UC = 25;
    uint8 public BOOST_CHIP_STRENGTH_R = 26;

    uint8 public BOOST_CHIP_INSIGHT_C = 27;
    uint8 public BOOST_CHIP_INSIGHT_UC = 28;
    uint8 public BOOST_CHIP_INSIGHT_R = 29;

    uint8 public BOOST_CHIP_PRECISION_C = 30;
    uint8 public BOOST_CHIP_PRECISION_UC = 31;
    uint8 public BOOST_CHIP_PRECISION_R = 32;

    uint8 public BOOST_CHIP_SOLID_C = 33;
    uint8 public BOOST_CHIP_SOLID_UC = 34;
    uint8 public BOOST_CHIP_SOLID_R = 35;

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;

    mapping(uint256 => ITEM_DETAIL) public itemDetail;

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        baseMetadata = _baseMetadata; 

        itemDetail[FAIRY_FEATHER_UC].amountLimit = 200;
        itemDetail[GOLEM_CORE_UC].amountLimit = 200;
        itemDetail[YUBA].amountLimit = 200;
        itemDetail[UNICORN_HORN_UC].amountLimit = 200;
        itemDetail[RED_JEWEL_UC].amountLimit = 200;
        itemDetail[CAT_WHISKER_UC].amountLimit = 200;
        itemDetail[WITCHS_WAND_UC].amountLimit = 200;
        itemDetail[IMP_TAIL_UC].amountLimit = 200;
        itemDetail[ODEN_UC].amountLimit = 200;
        itemDetail[AQUATIC_EGG_UC].amountLimit = 200;
        itemDetail[WAFUKU_UC].amountLimit = 200;
        itemDetail[SCHOOL_UNIFORM_UC].amountLimit = 200;
        itemDetail[MOFUMOFU_UC].amountLimit = 200;
        itemDetail[MAAT_UC].amountLimit = 200;
        itemDetail[INDESTRUCTIBLE_ICE_UC].amountLimit = 200;
        itemDetail[KAWAII_CANDY_UC].amountLimit = 200;
        itemDetail[DETERMINATION_OF_JUSTICE_UC].amountLimit = 200;
        itemDetail[KNOWLEDGE_OF_MALICE_UC].amountLimit = 200;
        itemDetail[SAKE_BARREL_UC].amountLimit = 200;
        itemDetail[MECHANICAL_BLADE_UC].amountLimit = 200;
        itemDetail[BELLYBAND_UC].amountLimit = 200;

        itemDetail[SECRET_DATA_C].amountLimit = 500;
        itemDetail[SECRET_DATA_UC].amountLimit = 100;
        itemDetail[SECRET_DATA_R].amountLimit = 20;

        itemDetail[BOOST_CHIP_STRENGTH_C].amountLimit = 300;
        itemDetail[BOOST_CHIP_STRENGTH_UC].amountLimit = 150;
        itemDetail[BOOST_CHIP_STRENGTH_R].amountLimit = 75;

        itemDetail[BOOST_CHIP_INSIGHT_C].amountLimit = 300;
        itemDetail[BOOST_CHIP_INSIGHT_UC].amountLimit = 150;
        itemDetail[BOOST_CHIP_INSIGHT_R].amountLimit = 75;

        itemDetail[BOOST_CHIP_PRECISION_C].amountLimit = 300;
        itemDetail[BOOST_CHIP_PRECISION_UC].amountLimit = 150;
        itemDetail[BOOST_CHIP_PRECISION_R].amountLimit = 75;

        itemDetail[BOOST_CHIP_SOLID_C].amountLimit = 300;
        itemDetail[BOOST_CHIP_SOLID_UC].amountLimit = 150;
        itemDetail[BOOST_CHIP_SOLID_R].amountLimit = 75;
    }

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
        uint256 remain = itemDetail[_itemId].amountLimit - itemDetail[_itemId].totalAmount;
        require(remain > 0, "FusionItem:: mint: exceeding");
        _mint(_addressTo, _itemId, _number, _data);
        itemDetail[_itemId].totalAmount++;
        emit mintTrainingItem(_addressTo, _itemId,_number, _data);
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
