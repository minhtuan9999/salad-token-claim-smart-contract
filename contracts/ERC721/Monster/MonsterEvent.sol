// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MonsterEDCSA.sol";

contract MonsterEvent is EDCSA {
    /*
     * create Monster NFT
     * @param _address: address of owner
     * @param tokenId: tokenId of monster
     * @param _type: type mint NFT
     */
    event createNFTMonster(address _address, uint256 tokenId, TypeMint _type);

    /*
     * fusion 2 Monster => monster
     * @param owner: address of owner
     * @param newMonster: new tokenId of Monster
     * @param firstTokenId: tokenId of monster fusion
     * @param lastTokenId: tokenId of monster fusion
     */
    event fusionMultipleMonster(
        address owner,
        uint256 newMonster,
        uint256 firstTokenId,
        uint256 lastTokenId
    );

    /*
     * fusion 2 genesis hash => monster
     * @param owner: address of owner
     * @param fistId: first tokenId of genesisHash
     * @param lastId: last tokenId of genesisHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionGenesisHashNFT(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId
    );
    /*
     * fusion 2 general hash => monster
     * @param owner: address of owner
     * @param fistId: first tokenId of generalHash
     * @param lastId: last tokenId of generalHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionGeneralHashNFT(
        address owner,
        uint256 fistId,
        uint256 lastId,
        uint256 newTokenId
    );
    /*
     * fusion genesishash + generalhash
     * @param owner: address of owner
     * @param genesisId: tokenId of genesisHash
     * @param generalId: tokenId of generalHash
     * @param newTokenId: new tokenId of Monster
     */
    event fusionMultipleHashNFT(
        address owner,
        uint256 genesisId,
        uint256 generalId,
        uint256 newTokenId
    );
    /*
     * refresh Times Of Regeneration
     * @param _type: type mint Monster
     * @param tokenId: tokenId of nft
     */
    event refreshTimesRegeneration(
        TypeMint _type,
        uint256 tokenId
    );
    /*
     * burn monster by id
     * @param tokenId: tokenId of nft
     */
    event burnMonster(uint256 tokenId);
    /*
     * set Status Monsters
     * @param tokenId: tokenId of nft
     * @param status: status of nft
     */
    event setStatusMonsters(uint256 tokenId,bool status);
}
