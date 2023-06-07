// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IT2WebERC721 {
    function setBaseURI(string memory baseTokenURI) external;

    function mint(address to) external returns (uint256);

    function burn(uint256 tokenId) external;

    function maxSupply() external view returns (uint256);

    function totalSupply() external view returns (uint256);
}

contract BridgeHashChipNFT is AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    IT2WebERC721 private hashChipNFT;

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param addressHashChip - token OAS address

     
     */
    constructor(address addressHashChip) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());

        hashChipNFT = IT2WebERC721(addressHashChip);
    }

        /**
     * @dev Creates a new market item.
     * @param tokenId: token ID of haschip NFT
     */
    function deposit(
        uint256 tokenId
    )
        public
        whenNotPaused
        onlyRole(MANAGERMENT_ROLE)
    {
        hashChipNFT.burn(tokenId);
    }
}
