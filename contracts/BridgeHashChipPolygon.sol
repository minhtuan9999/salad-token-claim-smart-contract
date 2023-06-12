// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract BridgeHashChipNFT is AccessControl, Pausable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public validator;
    mapping(address => mapping (bytes => bool)) private userBridged;

    constructor() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        validator = _msgSender();
    }

    function encodeBridge(
        address to,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(to, tokenId, chainId, deadline));
    }

    function recoverBridge(
        address to,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline,
        bytes calldata sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeBridge(to, tokenId, chainId, deadline)
                ),
                sig
            );
    }

    function bridgeHashChipNFT(
        address to,
        uint256 tokenId,
        uint256 deadline,
        bytes calldata sig
    ) public whenNotPaused onlyRole(ADMIN_ROLE) {
        require(deadline > block.timestamp, "Deadline exceeded");
        require(!userBridged[_msgSender()][sig], "Bridged Hash Chip");
        address signer = recoverBridge(
            to,
            tokenId,
            block.chainid,
            deadline,
            sig
        );
        require(signer == validator, "Validator fail signature");
        //Mint NFT

        userBridged[_msgSender()][sig] = true;
    }
}
