// SPDX-License-Identifier: MIT

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
//        .----------------. .----------------. .----------------. .----------------.
//       | .--------------. | .--------------. | .--------------. | .--------------. |
//       | |    _______   | | |  ____  ____  | | |     ____     | | |   ______     | |
//       | |   /  ___  |  | | | |_   ||   _| | | |   .'    `.   | | |  |_   __ \   | |
//       | |  |  (__ \_|  | | |   | |__| |   | | |  /  .--.  \  | | |    | |__) |  | |
//       | |   '.___`-.   | | |   |  __  |   | | |  | |    | |  | | |    |  ___/   | |
//       | |  |`\____) |  | | |  _| |  | |_  | | |  \  `--'  /  | | |   _| |_      | |
//       | |  |_______.'  | | | |____||____| | | |   `.____.'   | | |  |_____|     | |
//       | |              | | |              | | |              | | |              | |
//       | '--------------' | '--------------' | '--------------' | '--------------' |
//       '----------------' '----------------' '----------------' '----------------'
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC721NFT {
    function createNFT(address _address, uint256 _type) external;
}

contract ReMonsterShop is Ownable, ReentrancyGuard, AccessControl, Pausable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    IERC20 public tokenBase;

    address public addressReceive;
    Asset[] public listAsset;

    struct Asset {
        bool active;
        bytes32 id;
        uint256 typeNFT;
        address contractAddress;
        // Price (in wei) for the published item
        uint256 priceInWei;
        uint256 startTime;
        uint256 endTime;
        uint256 timeCreated;
    }

    // From ERC721 registry assetId to Asset (to avoid asset collision)
    mapping(address => mapping(uint256 => Asset)) public orderByAssetId;

    // EVENTS
    event NewAssetSuccessful(
        uint256 typeNFT,
        address contractAddress,
        uint256 priceInWei,
        uint256 startTime,
        uint256 endTime,
        uint256 timeCreated
    );

    event RemoveAssetSuccessful(uint256 typeNFT, address contractAddress);

    event BuyAssetSuccessful(
        address contractAddress,
        uint256 typeNFT,
        uint256 amount
    );

    event ChangedAddressReceive(address addressReceive);

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param _addressReceice - Recipient address
     * @param addressTokenBase - token OAS address
     */
    constructor(address _addressReceice, address addressTokenBase) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        // Fee init
        setNewAddress(_addressReceice);
        // token init
        tokenBase = IERC20(addressTokenBase);
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Set new address
     * @param _newAddress: new address
     */
    function setNewAddress(
        address _newAddress
    ) public onlyRole(MANAGERMENT_ROLE) {
        addressReceive = _newAddress;
        emit ChangedAddressReceive(addressReceive);
    }

    function removeListAsset(bytes32 id) internal {
        for (uint256 i = 0; i < listAsset.length; i++) {
            if (listAsset[i].id == id) {
                listAsset[i] = listAsset[listAsset.length - 1];
            }
        }
        listAsset.pop();
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     * @param priceInWei: price in tokenBase
     * @param startTime: Start time asset
     * @param endTime: End time asset
     */
    function createAsset(
        address contractAddress,
        uint256 typeNFT,
        uint256 priceInWei,
        uint256 startTime,
        uint256 endTime
    )
        public
        nonReentrant
        whenNotPaused
        onlyRole(MANAGERMENT_ROLE)
        returns (Asset memory newAsset)
    {
        newAsset = _createAsset(
            contractAddress,
            typeNFT,
            priceInWei,
            startTime,
            endTime
        );
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     * @param priceInWei: price in tokenBase
     * @param startTime: Start time asset
     * @param endTime: End time asset
     */
    function _createAsset(
        address contractAddress,
        uint256 typeNFT,
        uint256 priceInWei,
        uint256 startTime,
        uint256 endTime
    ) internal returns (Asset memory newAsset) {
        if (isERC721(contractAddress) || isERC1155(contractAddress)) {
            require(
                !orderByAssetId[contractAddress][typeNFT].active,
                "ReMonsterShop::createAsset: Asset already exists"
            );
            require(
                priceInWei > 0,
                "ReMonsterShop::createAsset: Price should be bigger than 0"
            );

            require(
                block.timestamp <= startTime,
                "ReMonsterShop::createAsset: Start time must be now or in the future"
            );

            require(
                startTime < endTime,
                "ReMonsterShop::createAsset: Start time must be before end time"
            );

            uint256 timeCreated = block.timestamp;

            bytes32 id = keccak256(
                abi.encodePacked(
                    typeNFT,
                    contractAddress,
                    priceInWei,
                    startTime,
                    endTime,
                    timeCreated
                )
            );

            newAsset = Asset(
                true,
                id,
                typeNFT,
                contractAddress,
                priceInWei,
                startTime,
                endTime,
                timeCreated
            );
            orderByAssetId[contractAddress][typeNFT] = newAsset;
            listAsset.push(newAsset);

            emit NewAssetSuccessful(
                typeNFT,
                contractAddress,
                priceInWei,
                startTime,
                endTime,
                timeCreated
            );
        } else {
            revert("ReMonsterShop::createAsset: Unsupported contract");
        }
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     */
    function removeAsset(
        address contractAddress,
        uint256 typeNFT
    ) public whenNotPaused onlyRole(MANAGERMENT_ROLE) {
        _removeAsset(contractAddress, typeNFT);
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     */
    function _removeAsset(address contractAddress, uint256 typeNFT) internal {
        Asset memory asset = orderByAssetId[contractAddress][typeNFT];
        // require(block.timestamp >= asset.endTime, 'ReMonsterShop::removeAsset: Cannot end asset before end time');
        require(asset.active, "ReMonsterShop::removeAsset: Asset not exists");

        removeListAsset(asset.id);
        delete orderByAssetId[contractAddress][typeNFT];
        emit RemoveAssetSuccessful(typeNFT, contractAddress);
    }

    function isERC721(address contractAddress) internal view returns (bool) {
        try
            IERC721(contractAddress).supportsInterface(
                type(IERC721).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    function isERC1155(address contractAddress) internal view returns (bool) {
        try
            IERC1155(contractAddress).supportsInterface(
                type(IERC1155).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     * @param amount: Amount NFT
     */
    function buyItem(
        address contractAddress,
        uint256 typeNFT,
        uint256 amount
    ) public nonReentrant whenNotPaused {
        _buyAsset(contractAddress, typeNFT, amount);
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param typeNFT: Type NFT
     * @param amount: Amount NFT
     */

    function _buyAsset(
        address contractAddress,
        uint256 typeNFT,
        uint256 amount
    ) internal {
        Asset memory asset = orderByAssetId[contractAddress][typeNFT];
        require(asset.active, "ReMonsterShop::buyAsset: Asset not exists");
        require(
            block.timestamp >= asset.startTime,
            "ReMonsterShop::buyAsset: Asset not started"
        );
        require(
            block.timestamp < asset.endTime,
            "ReMonsterShop::buyAsset: Asset ended"
        );

        uint256 totalPrice = asset.priceInWei.mul(amount);

        // Transfer sale amount to contract
        require(
            tokenBase.transferFrom(msg.sender, address(this), totalPrice),
            "ReMonsterShop::buyAsset: Transfering to the Shop contract failed"
        );

        // Transfer sale amount to ADMIN
        require(
            tokenBase.transfer(addressReceive, totalPrice),
            "ReMonsterShop::buyAsset: Transfering to the ADMIN contract failed"
        );

        for (uint256 index = 0; index < amount; index++) {
            IERC721NFT(asset.contractAddress).createNFT(msg.sender, typeNFT);
        }

        emit BuyAssetSuccessful(contractAddress, typeNFT, amount);
    }

    function getListAsset() public view returns (Asset[] memory) {
        return listAsset;
    }

    function getInfoAsset(
        address contractAddress,
        uint256 typeNFT
    ) public view returns (Asset memory result) {
        result = orderByAssetId[contractAddress][typeNFT];
    }
}
