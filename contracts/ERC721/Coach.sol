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

interface IMonster {
    function burn(uint256 _tokenId) external;

    function getStatusMonster(uint256 _tokenId) external view returns (bool);

    function isFreeMonster(uint256 _tokenId) external view returns (bool);
}

interface IMonsterMemory {
    function mint(address _address, uint256 _monsterId) external;
}

contract Coach is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard {
    IMonster monsterContract;
    IMonsterMemory monsterMemory;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    constructor() ERC721("Coach NFT", "Coach") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) _listTokensOfAddress;
    // Mapping info Coach
    mapping(uint256 => coachDetail) _coach;

    // struc if coach, if free => true
    struct coachDetail {
        bool isFree;
    }
    // Event create Coach
    event createCoach(address _address, uint256 _tokenId, uint256 _typeNFT);
    // Create coach from monster
    event createCoachByMonster(
        address _owner,
        uint256 _newCoach,
        uint256 _tokenBurn
    );

    // Get list token of address
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    // Set monster contract address
    function setMonsterContract(
        IMonster _monster
    ) external onlyRole(MANAGEMENT_ROLE) {
        monsterContract = _monster;
    }

    // Set monster contract address
    function setMonsterMemory(
        IMonsterMemory _monsterMemory
    ) external onlyRole(MANAGEMENT_ROLE) {
        monsterMemory = _monsterMemory;
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
        _listTokensOfAddress[to].add(firstTokenId);
        _listTokensOfAddress[from].remove(firstTokenId);
    }

    // Base URI
    string private _baseURIextended;

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    // Base mint NFT
    function _createNFT(address _address) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        _listTokensOfAddress[_address].add(tokenId);
        return tokenId;
    }

    /*
     * mint a Coach
     * @param _uri: _uri of NFT
     * @param _address: owner of NFT
     */
    function createNFT(
        address _address,
        uint256 _typeNFT
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 tokenId = _createNFT(_address);
        emit createCoach(_address, tokenId, _typeNFT);
    }

    /*
     * Create coach from Monster
     * @param _owner: address of owner
     * @param _idBurn: id monster burn
     */
    function createCoachFromMonster(
        address _owner,
        uint256 _monsterId
    ) external nonReentrant whenNotPaused {
        require(
            IERC721(address(monsterContract)).ownerOf(_monsterId) == _owner,
            "The owner is not correct"
        );
        bool isStatusMonster = monsterContract.getStatusMonster(_monsterId);
        require(!isStatusMonster,"The monster is alive");
        bool isFreeMonster = monsterContract.isFreeMonster(_monsterId);
        uint256 tokenId = _createNFT(msg.sender);
        if (isFreeMonster) {
            _coach[tokenId].isFree = true;
        }
        monsterMemory.mint(_owner, _monsterId);
        monsterContract.burn(_monsterId);
        emit createCoachByMonster(_owner, tokenId, _monsterId); 
    }

    /*
     * burn a Coach
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external nonReentrant {
        require(hasRole(MANAGEMENT_ROLE, _msgSender()) || ownerOf(_tokenId) == _msgSender(), "You not permission");
        _burn(_tokenId);
    }

    /*
     * check coach is free?
     * @param _tokenId: tokenId
     */
    function isFree(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Coach:: isFree: Coach not exists");
        return _coach[tokenId].isFree;
    }
}
