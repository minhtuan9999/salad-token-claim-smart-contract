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

    address public addressReceive;

    Asset[] public listAsset;

    struct Asset {
        bool active;
        address contractAddress;
        // Price (in wei) for the published item
        uint256 priceInWei;
    }

    // From ERC721 registry assetId to Asset (to avoid asset collision)
    mapping(address => Asset) public assetByAddress;

    // EVENTS
    event NewAssetSuccessful(address contractAddress, uint256 priceInWei);

    event RemoveAssetSuccessful(address contractAddress);

    event BuyAssetSuccessful(address contractAddress, uint256 amount);

    event ChangedAddressReceive(address addressReceive);

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param _addressReceice - Recipient address
     */
    constructor(address _addressReceice) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        // Fee init
        setNewAddress(_addressReceice);
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
    function setNewAddress(address _newAddress)
        public
        onlyRole(MANAGERMENT_ROLE)
    {
        addressReceive = _newAddress;
        emit ChangedAddressReceive(addressReceive);
    }

    function removeListAsset(address _address) internal {
        for (uint256 i = 0; i < listAsset.length; i++) {
            if (listAsset[i].contractAddress == _address) {
                listAsset[i] = listAsset[listAsset.length - 1];
            }
        }
        listAsset.pop();
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param priceInWei: price in tokenBase
     */
    function createAsset(address contractAddress, uint256 priceInWei)
        public
        nonReentrant
        whenNotPaused
        onlyRole(MANAGERMENT_ROLE)
        returns (Asset memory newAsset)
    {
        newAsset = _createAsset(contractAddress, priceInWei);
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param priceInWei: price in tokenBase
     */
    function _createAsset(address contractAddress, uint256 priceInWei)
        internal
        returns (Asset memory newAsset)
    {
        if (isERC721(contractAddress) || isERC1155(contractAddress)) {
            require(
                !assetByAddress[contractAddress].active,
                "ReMonsterShop::createAsset: Asset already exists"
            );
            require(
                priceInWei > 0,
                "ReMonsterShop::createAsset: Price should be bigger than 0"
            );

            newAsset = Asset(true, contractAddress, priceInWei);
            assetByAddress[contractAddress] = newAsset;
            listAsset.push(newAsset);

            emit NewAssetSuccessful(contractAddress, priceInWei);
        } else {
            revert("ReMonsterShop::createAsset: Unsupported contract");
        }
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     */
    function removeAsset(address contractAddress)
        public
        whenNotPaused
        onlyRole(MANAGERMENT_ROLE)
    {
        _removeAsset(contractAddress);
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     */
    function _removeAsset(address contractAddress) internal {
        Asset memory asset = assetByAddress[contractAddress];
        require(asset.active, "ReMonsterShop::removeAsset: Asset not exists");

        removeListAsset(contractAddress);
        delete assetByAddress[contractAddress];
        emit RemoveAssetSuccessful(contractAddress);
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
     * @param amount: Amount NFT
     */
    function buyItem(address contractAddress, uint256 amount, uint256 _type)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        Asset memory asset = assetByAddress[contractAddress];
        uint256 totalPrice = asset.priceInWei.mul(amount);

        require(asset.active, "ReMonsterShop::buyAsset: Asset not exists");
        require(
            totalPrice == msg.value,
            "ReMonsterShop::buyAsset: The price is not correct"
        );

        // Transfer sale amount to ADMIN
        require(
            payable(addressReceive).send(totalPrice),
            "ReMonsterShop::buyAsset: Transfering to the ADMIN contract failed"
        );

        for (uint256 index = 0; index < amount; index++) {
            IERC721NFT(asset.contractAddress).createNFT(msg.sender, _type);
        }

        emit BuyAssetSuccessful(contractAddress, amount);
    }

    function getListAsset() public view returns (Asset[] memory) {
        return listAsset;
    }

    function getInfoAsset(address contractAddress)
        public
        view
        returns (Asset memory result)
    {
        result = assetByAddress[contractAddress];
    }
}
