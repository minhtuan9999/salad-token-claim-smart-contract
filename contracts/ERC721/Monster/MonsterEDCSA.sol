// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EDCSA {
    // type 0: EXTERNAL_NFT
    // type 1: GENESIS_HASH
    // type 2: GENERAL_HASH
    // type 3: HASH_CHIP_NFT
    // type 4: REGENERATION_ITEM
    // type 5: FREE
    enum TypeMint {
        EXTERNAL_NFT,
        GENESIS_HASH,
        GENERAL_HASH,
        HASH_CHIP_NFT,
        REGENERATION_ITEM,
        FREE,
        FUSION
    }

    /*
     * encode data 
     * @param _type: type mint Monster
     * @param cost: fee mint NFT
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     */
    function encodeOAS(
        TypeMint _type,
        uint256 cost,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_type, cost, tokenId, chainId, deadline));
    }

    /*
     * recover data 
     * @param _type: type mint Monster
     * @param cost: fee mint NFT
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     * @param signature: signature encode data
     */
    function recoverOAS(
        TypeMint _type,
        uint256 cost,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline,
        bytes calldata signature 
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeOAS(_type, cost, tokenId, chainId, deadline)
                ),
                signature 
            );
    }
}
