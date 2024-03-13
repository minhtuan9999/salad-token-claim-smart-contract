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

contract MonsterCrystal is Ownable, ERC721Enumerable, AccessControl, Pausable, ReentrancyGuard {
    IMonster monsterContract;
    IMonsterMemory monsterMemory;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // Count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    constructor() ERC721("Monster Crystal", "Crystal") {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
    }

    // mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;
    mapping(uint256 => crystalDetail) private _crystal;
    // stuct of monster crystal
    struct crystalDetail {
        bool isFree;
    }

    // Event create Monster Crystal
    event createMonsterCrystal(
        address _address,
        uint256 _tokenId,
        uint256 _typeNFT
    );
    // Create coach from monster
    event createCrystalByMonster(
        address _owner,
        uint256 _crystalId,
        uint256 _monsterId
    );

    // Get list Tokens of address
    function getListTokensOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return _listTokensOfAddress[_address].values();
    }

    // Set monster contract address
    function initSetMonsterContract(
        IMonster _monster
    ) external onlyRole(MANAGEMENT_ROLE) {
        monsterContract = _monster;
    }

    // Set monster contract address
    function initSetMonsterMemory(
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

    /*
     * base mint a Monster Crystal
     * @param _address: owner of NFT
     */

    function _createNFT(address _address) private returns (uint256) {
        uint256 tokenId = _tokenIds.current();
        _mint(_address, tokenId);
        _tokenIds.increment();
        return tokenId;
    }

    /*
     * mint a Monster Crystal
     * @param _address: owner of NFT
     * @param _typeNFT: owner of NFT
     */

    function createNFT(
        address _address,
        uint256 _typeNFT
    ) external nonReentrant whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        uint256 tokenId = _createNFT(_address);
        emit createMonsterCrystal(_address, tokenId, _typeNFT);
    }

    /*
     * Create coach from Monster
     * @param _owner: address of owner
     * @param _monsterId: last tokenId monster fusion
     */
    function createCrystalFromMonster(
        uint256 _monsterId
    ) external nonReentrant whenNotPaused {
        require(
            IERC721(address(monsterContract)).ownerOf(_monsterId) == msg.sender,
            "MonsterManagerment: createCoachNFT: The owner is not correct"
        );
        bool isStatusMonster = monsterContract.getStatusMonster(_monsterId);
        require(
            !isStatusMonster,
            "MonsterManagerment: createCoachNFT: The monster is alive"
        );
        bool isFreeMonster = monsterContract.isFreeMonster(_monsterId);
        uint256 tokenId = _createNFT(msg.sender);
        if (isFreeMonster) {
            _crystal[tokenId].isFree = true;
        }
        monsterContract.burn(_monsterId);
        monsterMemory.mint(msg.sender, _monsterId);
        emit createCrystalByMonster(msg.sender, tokenId, _monsterId);
    }

    /*
     * burn a Monster
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external nonReentrant {
        require(hasRole(MANAGEMENT_ROLE, _msgSender()) || ownerOf(_tokenId) == _msgSender(), "You not permission");
        _burn(_tokenId);
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function isFree(uint256 tokenId) external view returns (bool) {
        require(
            _exists(tokenId),
            "Monster Crystal:: isFree: Monster not exists"
        );
        return _crystal[tokenId].isFree;
    }
}
