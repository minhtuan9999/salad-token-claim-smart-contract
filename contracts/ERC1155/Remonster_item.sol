//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract RemonsterItem  is ERC1155,AccessControl, Ownable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    bytes32 public constant MANAGERMENT_ITEM_ROLE = keccak256("MANAGERMENT_ITEM_ROLE");

    using Strings for uint256;

    constructor(string memory _baseMetadata) ERC1155(_baseMetadata) {
        //"https://gateway.pinata.cloud/ipfs/QmTN32qBKYqnyvatqfnU8ra6cYUGNxpYziSddCatEmopLR/metadata/api/item/{id}.json"
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        _setRoleAdmin(MANAGERMENT_ITEM_ROLE, MANAGERMENT_ITEM_ROLE);
        _setupRole(MANAGERMENT_ITEM_ROLE, _msgSender());
        baseMetadata = _baseMetadata;
    }

    string public baseMetadata;

    // EVENT 
    event mintMonsterItems(address _addressTo, uint256 _tokenId, uint256 _number, bytes _metadata);
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
    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return  string(abi.encodePacked(baseMetadata, tokenId.toString()));
    }

    function setBaseMetadata(string memory _baseMetadata) public onlyOwner {
        baseMetadata = _baseMetadata;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /*
     * mint a Training item
     * @param addressTo: owner of NFT
     * @oaram tokenId: id of item
     * @param number: number NFT
     * @param data: information of NFT
     * List tokenId:
     *      TRAINING_ITEM = 0;
     *      REGENERATION_ITEM= 1;
     *      FUSION_ITEM = 2;
     *      MATERIAL_ITEM = 3;
     *      EXPEDITION_TICKET = 5;
     *      TOURNAMENT_TICKET = 6; 
     */
    function mintMonsterItem(address _addressTo,uint256 _tokenId, uint256 _number, bytes memory _data ) public onlyRole(MANAGERMENT_ROLE){
        _mint(_addressTo,_tokenId,_number,_data);
        emit mintMonsterItems(_addressTo, _tokenId, _number, _data);
    }

    function burnMonsterItem(address _from,uint256 _id,uint256 _amount) external {
        require(hasRole(MANAGERMENT_ITEM_ROLE, msg.sender), "Not permission");
        _burn(_from, _id, _amount);
    }
}