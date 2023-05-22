// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GenesisHash is Ownable, ReentrancyGuard,ERC721Enumerable, AccessControl, Pausable {
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // stored current packageId
    Counters.Counter private _tokenIds;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");
    bytes32 public constant MANAGERMENT_NFT_ROLE = keccak256("MANAGERMENT_ROLE");

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setRoleAdmin(MANAGERMENT_NFT_ROLE, MANAGERMENT_NFT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        _setupRole(MANAGERMENT_NFT_ROLE, _msgSender());
    }
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    // Event create Monster
    event createGenesisHash(address _address, uint256 _tokenId);

    // Get holder Tokens
    function getHolderToken(address _address) public view returns(uint256[] memory){
        return _holderTokens[_address].values();
    }

    // Set managerment role
    function setManagermentRole(address _address) public onlyOwner{
        require(!hasRole(MANAGERMENT_ROLE, _address), "Monster: Readly Role");
        _setupRole(MANAGERMENT_ROLE, _address);
    }
    // Set managerment nft role
    function setManagermentNFTRole(address _address) public onlyOwner{
        require(!hasRole(MANAGERMENT_NFT_ROLE, _address), "Monster: Readly Role");
        _setupRole(MANAGERMENT_NFT_ROLE, _address);
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
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        _holderTokens[to].add(firstTokenId);
        _holderTokens[from].remove(firstTokenId);
    }

    // Base URI
    string private _baseURIextended;

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function pause() public onlyRole(MANAGERMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGERMENT_ROLE) {
        _unpause();
    }

    /*
     * mint a Genesishash
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */
    
    function createNFT(
        address _address
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _holderTokens[_address].add(tokenId);
        emit createGenesisHash(_address, tokenId);
    } 

    /*
     * mint a Genesishash
     * @param _address: owner of NFT
     */
    
    function mintGenesishash(
        address _address
    ) external returns(uint256) {
        require(hasRole(MANAGERMENT_NFT_ROLE, msg.sender), "Monster: Not permission");
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _holderTokens[_address].add(tokenId);
        return tokenId;
    } 

    /*
     * burn a Genesishash
     * @param _tokenId: tokenId burn
     */
    function burnGenesisHash(uint256 _tokenId) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        require(_exists(_tokenId), "Token id not exist");
        _burn(_tokenId);
    }


}   
