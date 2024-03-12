// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TrainerLicense is
    Ownable,
    ERC721Enumerable,
    AccessControl,
    Pausable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // Count token id
    Counters.Counter _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE  = keccak256("MANAGEMENT_ROLE");
    // Base URI
    string _baseURIextended;

    constructor() ERC721("TrainerLicense", "TrainerLicense") {
        _setRoleAdmin(MANAGEMENT_ROLE , MANAGEMENT_ROLE );
        _setupRole(MANAGEMENT_ROLE , _msgSender());
    }

    // Mapping list token id of owner
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;

    /*
     * mint TrainerLicense
     * @param _address: address of owner
     * @param tokenId: tokenId
     */
    event MintTrainerLicense(address _address, uint256 tokenId);

    /*
     * burn TrainerLicense
     * @param tokenId: tokenId 
     */
    event BurnTrainerLicense(uint256 tokenId);

    // Get list Tokens of address
    function getListTokenOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    /**
     *@dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        if (from == address(0) || to == address(0) ) {
            super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
            _listTokensOfAddress[to].add(firstTokenId);
            _listTokensOfAddress[from].remove(firstTokenId);
        } else {
            revert("TrainerLicense is not transferrable");
        }
    }

    /*
     * setBase URI
     * @param baseURI_: baseURI_ of NFT
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    /*
     * base URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    /*
     * supports Interface
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*
     * pause contract ny Management 
     */
    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }
    
    /*
     * unpause contract ny Management 
     */
    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    /*
     * mint a TrainerLicens
     * @param _address: owner of NFT
     */
    function mintTrainerLicense(address _address) public onlyRole(MANAGEMENT_ROLE) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        emit MintTrainerLicense(_address, tokenId);
    }
    
    /*
     * burn TrainerLicens
     * @param _tokenId: tokenId 
     */
    function burnTrainerLicense(uint256 _tokenId) external{
        require(hasRole(MANAGEMENT_ROLE, _msgSender()) || ownerOf(_tokenId) == _msgSender(), "You not permission");
        _burn(_tokenId);
        emit BurnTrainerLicense(_tokenId);
    }
}
