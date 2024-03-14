// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IHashChip {
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
contract BridgeHashChip is AccessControl, Pausable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    using EnumerableSet for EnumerableSet.UintSet;

    IHashChip public hashChipContract;
    address public validator;
    mapping(address => mapping (bytes => bool)) private userBridged;
    mapping(address => EnumerableSet.UintSet) listTokenBridgeOfAddress;

    event BridgeNFT(address from, uint256 tokenId, uint256 toChainId);

    constructor(IHashChip _hashChipContract) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();
        hashChipContract = _hashChipContract;
    }

    // Get list Tokens bridge of address
    function getListTokenBridgeOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return listTokenBridgeOfAddress[_address].values();
    }

    // Set hashchip contract address
    function setHashChipAddress(
        IHashChip _hashChipContract
    ) external onlyRole(MANAGEMENT_ROLE) {
        hashChipContract = _hashChipContract;
    }

    /**
     * @dev Bridge NFT 
     * @param tokenId: tokenId bridge
     * @param toChainId: chain bridge
     */
    function bridgeNFT(uint256 tokenId, uint256 toChainId) external {
        require(hashChipContract.ownerOf(tokenId) == msg.sender, "Bridge: You not owner");
        hashChipContract.burn(tokenId);
        listTokenBridgeOfAddress[msg.sender].add(tokenId);
        emit BridgeNFT(msg.sender, tokenId, toChainId);
    }

}
