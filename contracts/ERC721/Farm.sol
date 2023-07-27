// SPDX-License-Identifier: CC0-1.0
//
//
//    /$$$$$$$                /$$      /$$                                 /$$
//   | $$__  $$              | $$$    /$$$                                | $$
//   | $$  \ $$  /$$$$$$     | $$$$  /$$$$  /$$$$$$  /$$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$
//   | $$$$$$$/ /$$__  $$    | $$ $$/$$ $$ /$$__  $$| $$__  $$ /$$_____/|_  $$_/   /$$__  $$ /$$__  $$
//   | $$__  $$| $$$$$$$$    | $$  $$$| $$| $$  \ $$| $$  \ $$|  $$$$$$   | $$    | $$$$$$$$| $$  \__/
//   | $$  \ $$| $$_____/    | $$\  $ | $$| $$  | $$| $$  | $$ \____  $$  | $$ /$$| $$_____/| $$
//   | $$  | $$|  $$$$$$$ /$$| $$ \/  | $$|  $$$$$$/| $$  | $$ /$$$$$$$/  |  $$$$/|  $$$$$$$| $$
//   |__/  |__/ \_______/|__/|__/     |__/ \______/ |__/  |__/|_______/    \___/   \_______/|__/
//
//            .----------------. .----------------. .----------------. .----------------.
//           | .--------------. | .--------------. | .--------------. | .--------------. |
//           | |  _________   | | |      __      | | |  _______     | | | ____    ____ | |
//           | | |_   ___  |  | | |     /  \     | | | |_   __ \    | | ||_   \  /   _|| |
//           | |   | |_  \_|  | | |    / /\ \    | | |   | |__) |   | | |  |   \/   |  | |
//           | |   |  _|      | | |   / ____ \   | | |   |  __ /    | | |  | |\  /| |  | |
//           | |  _| |_       | | | _/ /    \ \_ | | |  _| |  \ \_  | | | _| |_\/_| |_ | |
//           | | |_____|      | | ||____|  |____|| | | |____| |___| | | ||_____||_____|| |
//           | |              | | |              | | |              | | |              | |
//           | '--------------' | '--------------' | '--------------' | '--------------' |
//            '----------------' '----------------' '----------------' '----------------'

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./Interface/IERC4907.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ReMonsterFarm is
    Ownable,
    ERC721Enumerable,
    IERC4907,
    AccessControl,
    ReentrancyGuard,
    Pausable
{
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    // stored current packageId
    Counters.Counter private _tokenIds;
    // Base URI
    string private _baseURIextended;
    uint256 private totalLimit;

    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    struct MonsterInfo {
        address owner;
        bool isTraining;
        IERC721 monsterContract;
        uint256 tokenId;
    }

    mapping(address => EnumerableSet.UintSet) private userToListFarm;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    mapping(uint256 => UserInfo) internal _users;

    // ID Farm => Info Monster
    mapping(uint256 => MonsterInfo) internal training;

    // EVENTS
    event NewFarm(uint256 typeNFT, uint256 tokenId, address owner);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 limit
    ) ERC721(name_, symbol_) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        totalLimit = limit;
    }

    function setBaseURI(string memory baseURI_) external onlyRole(MANAGERMENT_ROLE) {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function trainingMonster(
        IERC721 monsterContract,
        uint256 farmId,
        uint256 monsterId
    ) public {
        require(!training[farmId].isTraining, "ReMonsterFarm::trainingMonster: Training already exists");
        require(
            ERC721.ownerOf(farmId) == msg.sender,
            "ReMonsterFarm::trainingMonster::ERC721: Incorrect farm owner"
        );

        // tokenId must be approved for this contract
        monsterContract.transferFrom(msg.sender, address(this), monsterId);
        training[farmId] = MonsterInfo({
            owner: msg.sender,
            isTraining: true,
            monsterContract: monsterContract,
            tokenId: monsterId
        });
    }

    function endTrainingMonster(
        IERC721 monsterContract,
        uint256 farmId,
        uint256 monsterId
    ) public {
        require(training[farmId].isTraining, "ReMonsterFarm::endTrainingMonster: Training does not exist");
        address ownerMonster = training[farmId].owner;
        require(
            ownerMonster == msg.sender || msg.sender == owner(),
            "ReMonsterFarm::endTrainingMonster: Unauthorized user"
        );

        monsterContract.transferFrom(address(this), ownerMonster, monsterId);
        delete training[farmId];
    }

    function createNFT(
        address _address,
        uint256 _type
    ) external nonReentrant whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _createFarm(_address, _type);
    }

    /**
     * create a farm and mint to owner
     * @param owner: owner of farm
     */
    function _createFarm(address owner, uint256 typeNFT) internal {
        require(totalSupply() < totalLimit, "Total supply reached the limit");
        uint256 tokenId = _tokenIds.current();
        _mint(owner, tokenId);
        userToListFarm[owner].add(tokenId);
        _tokenIds.increment();
        emit NewFarm(typeNFT, tokenId, owner);
    }

    /**
     * withdraw all erc20 token base balance of this contract
     */
    function withdrawToken(
        address contractAddress
    ) external onlyRole(ADMIN_ROLE) {
        uint256 balance = IERC20(contractAddress).balanceOf(address(this));
        require(balance > 0, "ReMonsterFarm::withdrawToken: Insufficient balance");
        IERC20(contractAddress).transfer(msg.sender, balance);
    }

    /**
     * Get list farm by address
     */
    function getListFarmByAddress(
        address _address
    ) public view returns (uint256[] memory listFarm) {
        listFarm = userToListFarm[_address].values();
    }

    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) external onlyRole(MANAGERMENT_ROLE) {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ReMonsterFarm::setUser::ERC721: transfer caller is not owner nor approved"
        );
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view virtual returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(
        uint256 tokenId
    ) public view virtual returns (uint256) {
        return _users[tokenId].expires;
    }

    /// @dev See {IERC165-supportsInterface}.
    // function supportsInterface(
    //     bytes4 interfaceId
    // ) public view virtual override returns (bool) {
    //     return
    //         interfaceId == type(IERC4907).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(AccessControl, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        userToListFarm[from].remove(tokenId);
        userToListFarm[to].add(tokenId);
        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }

    function getTotalLimit() external view returns (uint256) {
        return totalLimit;
    }
}
