// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IMonster {
    function burn(uint256 _tokenId) external;

    function getStatusMonster(uint256 _tokenId) external view returns (bool);

    function isFreeMonster(uint256 _tokenId) external view returns (bool);
}

interface IMonsterMemory {
    function mint(address _address, uint256 _monsterId) external;
}

contract Coach is Ownable, ERC721Enumerable, AccessControl, Pausable {
    IMonster monsterContract;
    IMonsterMemory monsterMemory;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    // count token id
    Counters.Counter private _tokenIds;
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    constructor() ERC721("Coach NFT", "Coach") {
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(MANAGERMENT_ROLE, _msgSender());
    }

    // Mapping list token of address
    mapping(address => EnumerableSet.UintSet) private _listTokensOfAddress;
    // Mapping info Coach
    mapping(uint256 => coachDetail) private _coach;

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
    ) external onlyRole(MANAGERMENT_ROLE) {
        monsterContract = _monster;
    }

    // Set monster contract address
    function setMonsterMemory(
        IMonsterMemory _monsterMemory
    ) external onlyRole(MANAGERMENT_ROLE) {
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

    function pause() public onlyRole(MANAGERMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGERMENT_ROLE) {
        _unpause();
    }

    // Base mint NFT
    function _createNFT(address _address) internal returns (uint256) {
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
    ) external whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        uint256 tokenId = _createNFT(_address);
        emit createCoach(_address, tokenId, _typeNFT);
    }

    /*
     * Create coach from Monster
     * @param _owner: address of owner
     * @param _idBurn: last tokenId monster fusion
     */
    function createCoachFromMonster(
        address _owner,
        uint256 _monsterId
    ) external whenNotPaused {
        require(
            IERC721(address(monsterContract)).ownerOf(_monsterId) == _owner,
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
            _coach[tokenId].isFree = true;
        }
        monsterContract.burn(_monsterId);
        monsterMemory.mint(_owner, _monsterId);
        emit createCoachByMonster(_owner, tokenId, _monsterId);
    }

    /*
     * burn a Monster
     * @param _tokenId: tokenId burn
     */
    function burn(uint256 _tokenId) external onlyRole(MANAGERMENT_ROLE) {
        _burn(_tokenId);
    }

    /*
     * staus lifespan a Monster
     * @param _tokenId: tokenId
     */
    function isFree(uint256 tokenId) external view returns (bool) {
        require(_exists(tokenId), "Coach:: isFree: Monster not exists");
        return _coach[tokenId].isFree;
    }
}
