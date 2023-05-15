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
//                 .----------------. .----------------. .----------------.
//                | .--------------. | .--------------. | .--------------. |
//                | | ____    ____ | | |  ___  ____   | | |   ______     | |
//                | ||_   \  /   _|| | | |_  ||_  _|  | | |  |_   __ \   | |
//                | |  |   \/   |  | | |   | |_/ /    | | |    | |__) |  | |
//                | |  | |\  /| |  | | |   |  __'.    | | |    |  ___/   | |
//                | | _| |_\/_| |_ | | |  _| |  \ \_  | | |   _| |_      | |
//                | ||_____||_____|| | | |____||____| | | |  |_____|     | |
//                | |              | | |              | | |              | |
//                | '--------------' | '--------------' | '--------------' |
//                 '----------------' '----------------' '----------------'
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ReMonsterMarketplace is
    Ownable,
    ReentrancyGuard,
    AccessControl,
    Pausable
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    IERC20 private tokenBase;

    // fee seller
    uint256 public feeSeller;
    address public addressReceiveFee;
    uint8 decimalsFee = 18;

    InfoItemSale [] public listSale;

    struct Order {
        bool active;
        // Owner of the NFT
        address seller;
        // Price (in wei) for the published item
        uint256 price;
        // Amount NFT
        uint256 amount;
    }

    struct InfoItemSale {
        bytes32 orderId;
        uint256 tokenId;
        address seller;
        uint256 priceInWei;
        uint256 amount;
    }

    // From ERC721 registry assetId to Order (to avoid asset collision)
    mapping(bytes32 => mapping(address => mapping(uint256 => Order)))
        public orderByAssetId;

    // EVENTS
    event OrderCreated(
        bytes32 id,
        uint256 indexed tokenId,
        address indexed seller,
        address nftAddress,
        uint256 priceInWei
    );

    event OrderSuccessful(
        bytes32 id,
        uint256 indexed tokenId,
        address indexed seller,
        address nftAddress,
        uint256 price,
        address indexed buyer
    );

    event OrderCancelled(
        bytes32 id,
        uint256 indexed tokenId,
        address indexed seller,
        address nftAddress
    );

    event ChangedFeeSeller(uint256 newFee);
    event ChangedAddressReceiveSeller(address addressReceiveFee);

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param _feeSeller - fee seller
     * @param _addressReceiceFee - fee recipient address
     */
    constructor(
        uint256 _feeSeller,
        address _addressReceiceFee,
        address addressTokenBase
    ) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        // Fee init
        setFeeSeller(_feeSeller);
        setNewAddressFee(_addressReceiceFee);

        tokenBase = IERC20(addressTokenBase);
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Set new decimals fee
     * @param _decimalsFee - new decimals fee seller
     */
    function setDecimalsFee(
        uint8 _decimalsFee
    ) public onlyRole(MANAGERMENT_ROLE) {
        decimalsFee = _decimalsFee;
    }

    /**
     * @dev Set new fee seller
     * @param _feeSeller - new fee seller
     */
    function setFeeSeller(
        uint256 _feeSeller
    ) public onlyRole(MANAGERMENT_ROLE) {
        feeSeller = _feeSeller;
        emit ChangedFeeSeller(feeSeller);
    }

    /**
     * @dev Set new address fee seller
     * @param _newAddressFee: new address fee seller
     */
    function setNewAddressFee(
        address _newAddressFee
    ) public onlyRole(MANAGERMENT_ROLE) {
        addressReceiveFee = _newAddressFee;
        emit ChangedAddressReceiveSeller(addressReceiveFee);
    }

    function removeListSale(bytes32 orderId) public {
        for (uint256 i = 0; i < listSale.length; i++) 
        {
            if (listSale[i].orderId == orderId) {
                listSale[i] = listSale[listSale.length - 1];
            }
        }
        listSale.pop();
    }

    /**
     * @dev Creates a new market item.
     * @param contracAddress: address of nft contract
     * @param tokenId: id of token in nft contract
     * @param priceInWei: price in tokenBase
     * @param amount: Amount token
     */
    function createMarketItemSale(
        address contracAddress,
        uint256 tokenId,
        uint256 priceInWei,
        uint256 amount
    ) public nonReentrant whenNotPaused {
        (bytes32 orderId, address nftOwner) = _createMarketItemSale(
            contracAddress,
            tokenId,
            priceInWei,
            amount
        );

        InfoItemSale memory newInfoItem = InfoItemSale(orderId, tokenId, msg.sender, priceInWei, amount);
        listSale.push(newInfoItem);
        emit OrderCreated(
            orderId,
            tokenId,
            nftOwner,
            contracAddress,
            priceInWei
        );
    }

    /**
     * @dev Creates a new market item.
     * @param contractAddress: address of nft contract
     * @param tokenId: id of token in nft contract
     * @param priceInWei: price in tokenBase
     * @param amount: Amount token
     */
    function _createMarketItemSale(
        address contractAddress,
        uint256 tokenId,
        uint256 priceInWei,
        uint256 amount
    ) internal returns (bytes32, address) {
        // Transfer NFT to the marketplace
        if (isERC721(contractAddress)) {
            IERC721 nftContract = IERC721(contractAddress);
            address nftOwner = nftContract.ownerOf(tokenId);
            require(nftOwner == msg.sender, "Only the owner can create orders");
            require(
                nftContract.getApproved(tokenId) == address(this) ||
                    nftContract.isApprovedForAll(nftOwner, address(this)),
                "The contract is not authorized to manage the asset"
            );
            require(priceInWei > 0, "Price should be bigger than 0");

            bytes32 orderId = keccak256(
                abi.encodePacked(
                    block.timestamp,
                    nftOwner,
                    tokenId,
                    contractAddress,
                    priceInWei
                )
            );

            orderByAssetId[orderId][contractAddress][tokenId] = Order({
                active: true,
                seller: nftOwner,
                price: priceInWei,
                amount: amount
            });

            return (orderId, nftOwner);
        } else if (isERC1155(contractAddress)) {
            IERC1155 nftContract = IERC1155(contractAddress);
            require(
                nftContract.balanceOf(msg.sender, tokenId) >= amount,
                "Insufficient balance"
            );
            require(
                nftContract.isApprovedForAll(msg.sender, address(this)),
                "The contract is not authorized to manage the asset"
            );
            require(priceInWei > 0, "Price should be bigger than 0");

            bytes32 orderId = keccak256(
                abi.encodePacked(
                    block.timestamp,
                    msg.sender,
                    tokenId,
                    contractAddress,
                    priceInWei,
                    amount
                )
            );

            orderByAssetId[orderId][contractAddress][tokenId] = Order({
                active: true,
                seller: msg.sender,
                price: priceInWei,
                amount: amount
            });

            return (orderId, msg.sender);
        } else {
            revert("Unsupported contract");
        }
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
     * @dev Cancel an already published market item
     *  can only be canceled by seller or the contract owner
     * @param contractAddress - The NFT registry
     * @param tokenId - ID of the published NFT
     */

    function cancelMarketItemSale(
        address contractAddress,
        bytes32 orderId,
        uint256 tokenId
    ) public nonReentrant whenNotPaused {
        _cancelMarketItemSale(contractAddress, orderId, tokenId);
        removeListSale(orderId);
    }

    /**
     * @dev Cancel an already published market item
     *  can only be canceled by seller or the contract owner
     * @param contractAddress - The NFT registry
     * @param tokenId - ID of the published NFT
     */
    function _cancelMarketItemSale(
        address contractAddress,
        bytes32 orderId,
        uint256 tokenId
    ) internal returns (Order memory order) {
        order = orderByAssetId[orderId][contractAddress][tokenId];
        require(order.active, "Asset not published");
        require(
            order.seller == msg.sender || msg.sender == owner(),
            "Unauthorized user"
        );

        address orderSeller = order.seller;
        delete orderByAssetId[orderId][contractAddress][tokenId];
        emit OrderCancelled(orderId, tokenId, orderSeller, contractAddress);
    }

    /**
     * @dev Buy item directly from a published NFT
     * @param contractAddress - The NFT registry
     * @param tokenId - ID of the published NFT
     */
    function buyItem(
        address contractAddress,
        bytes32 orderId,
        uint256 tokenId
    ) public whenNotPaused returns (Order memory order) {
        order = orderByAssetId[orderId][contractAddress][tokenId];
        require(order.active, "Asset not published");

        address seller = order.seller;

        require(seller != address(0), "Invalid address");
        require(seller != msg.sender, "Unauthorized user");
        if (isERC721(contractAddress)) {
            IERC721 nftContract = IERC721(contractAddress);
            require(
                seller == nftContract.ownerOf(tokenId),
                "The seller is no longer the owner"
            );

            // Transfer asset owner
            nftContract.safeTransferFrom(seller, msg.sender, tokenId);
        } else if (isERC1155(contractAddress)) {
            IERC1155 nftContract = IERC1155(contractAddress);
            // Transfer asset owner
            nftContract.safeTransferFrom(
                seller,
                msg.sender,
                tokenId,
                order.amount,
                ""
            );
        } else {
            revert("Unsupported contract");
        }

        uint256 saleShareAmount = 0;

        delete orderByAssetId[orderId][contractAddress][tokenId];

        if (feeSeller > 0) {
            // Calculate sale share
            saleShareAmount = order.price.mul(feeSeller).div(
                100 * 10 ** decimalsFee
            );

            // Transfer share amount for marketplace Owner
            require(
                tokenBase.transferFrom(
                    address(this),
                    addressReceiveFee,
                    saleShareAmount
                ),
                "Transfering the cut to the Marketplace owner failed"
            );
        }

        // Transfer sale amount to seller
        require(
            tokenBase.transferFrom(
                address(this),
                seller,
                order.price.sub(saleShareAmount)
            ),
            "Transfering the cut to the Marketplace owner failed"
        );

        removeListSale(orderId);

        emit OrderSuccessful(
            orderId,
            tokenId,
            seller,
            contractAddress,
            order.price,
            msg.sender
        );
    }
}
