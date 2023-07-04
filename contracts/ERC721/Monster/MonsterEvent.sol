// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MonsterEDCSA.sol";

contract MonsterEvent is EDCSA {
    /*
     * create Monster NFT
     * @param _address: address of owner
     * @param _tokenId: tokenId of monster
     * @param _type: type mint NFT
     */
    event createNFTMonster(address _address, uint256 _tokenId, TypeMint _type);

    /*
     * fusion 2 Monster => monster
     * @param _owner: address of owner
     * @param _newMonster: new tokenId of Monster
     * @param _firstTokenId: tokenId of monster fusion
     * @param _lastTokenId: tokenId of monster fusion
     */
    event fusionMultipleMonster(
        address _owner,
        uint256 _newMonster,
        uint256 _firstTokenId,
        uint256 _lastTokenId
    );

    /*
     * fusion 2 genesis hash => monster
     * @param _owner: address of owner
     * @param _fistId: first tokenId of genesisHash
     * @param _lastId: last tokenId of genesisHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionGenesisHashNFT(
        address _owner,
        uint256 _fistId,
        uint256 _lastId,
        uint256 _newTokenId
    );
    /*
     * fusion 2 general hash => monster
     * @param _owner: address of owner
     * @param _fistId: first tokenId of generalHash
     * @param _lastId: last tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionGeneralHashNFT(
        address _owner,
        uint256 _fistId,
        uint256 _lastId,
        uint256 _newTokenId
    );
    /*
     * fusion genesishash + generalhash
     * @param _owner: address of owner
     * @param _genesisId: tokenId of genesisHash
     * @param _generalId: tokenId of generalHash
     * @param _newTokenId: new tokenId of Monster
     */
    event fusionMultipleHashNFT(
        address _owner,
        uint256 _genesisId,
        uint256 _generalId,
        uint256 _newTokenId
    );
}
