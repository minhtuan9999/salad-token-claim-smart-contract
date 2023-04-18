//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RemonsterItem  is ERC1155,AccessControl {
    uint256 public constant TRAINING = 0;
    uint256 public constant PLAYBACK = 1;
    uint256 public constant FUSION = 2;
    uint256 public constant MATERIAL = 3;
    uint256 public constant ACCESSORIES= 4;
    uint256 public constant TICKET = 5;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    constructor(string memory metadata) ERC1155(metadata) {
        //"https://gateway.pinata.cloud/ipfs/QmTN32qBKYqnyvatqfnU8ra6cYUGNxpYziSddCatEmopLR/metadata/api/item/{id}.json"
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
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
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintTraining(address addressTo, uint256 number, bytes memory data ) public onlyRole(MANAGERMENT_ROLE){
        _mint(addressTo,TRAINING,number,data);
    }
    
    /*
     * mint a Playback item
     * @param addressTo: owner of NFT
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintPlayback(address addressTo, uint256 number, bytes memory data) public onlyRole(MANAGERMENT_ROLE){
       _mint(addressTo,PLAYBACK,number,data);
    }
    
    /*
     * mint a Fusion item
     * @param addressTo: owner of NFT
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintFusion(address addressTo, uint256 number, bytes memory data) public onlyRole(MANAGERMENT_ROLE){
       _mint(addressTo,FUSION,number,data);
    }
    
    /*
     * mint a Material item
     * @param addressTo: owner of NFT
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintMaterial(address addressTo, uint256 number, bytes memory data) public onlyRole(MANAGERMENT_ROLE){
        _mint(addressTo,MATERIAL,number,data);
    }
    
    /*
     * mint a Accessories item
     * @param addressTo: owner of NFT
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintAccessories(address addressTo, uint256 number, bytes memory data) public onlyRole(MANAGERMENT_ROLE){
        _mint(addressTo,ACCESSORIES,number,data);
    }
    
    /*
     * mint a Ticket item
     * @param addressTo: owner of NFT
     * @param number: number NFT
     * @param data: information of NFT
     */
    function mintTicket(address addressTo, uint256 number, bytes memory data) public onlyRole(MANAGERMENT_ROLE){
        _mint(addressTo,TICKET,number,data);
    }
}