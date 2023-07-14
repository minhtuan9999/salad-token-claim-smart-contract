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
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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

    // fee seller
    uint256 public feeSeller;
    address public addressReceiveFee;
    uint8 public decimalsFee = 18;

    InfoItemSale[] public listSale;

    struct Order {
        address contractAddress;
        uint256 tokenId;
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
        uint256 timeSale;
    }

    // From ERC721 registry assetId to Order (to avoid asset collision)
    mapping(bytes32 => Order) public orderByAssetId;

    // EVENTS
    event OrderCreated(
        bytes32 orderId,
        uint256 indexed tokenId,
        address indexed seller,
        address nftAddress,
        uint256 priceInWei
    );

    event OrderSuccessful(
        bytes32 orderId,
        uint256 indexed tokenId,
        address indexed seller,
        address nftAddress,
        uint256 priceInWei,
        address indexed buyer
    );

    event OrderCancelled(
        bytes32 orderId,
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
        address _addressReceiceFee
    ) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        // Fee init
        setFeeSeller(_feeSeller);
        setNewAddressFee(_addressReceiceFee);
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
    function setDecimalsFee(uint8 _decimalsFee)
        public
        onlyRole(MANAGERMENT_ROLE)
    {
        decimalsFee = _decimalsFee;
    }

    /**
     * @dev Set new fee seller
     * @param _feeSeller - new fee seller
     */
    function setFeeSeller(uint256 _feeSeller)
        public
        onlyRole(MANAGERMENT_ROLE)
    {
        feeSeller = _feeSeller;
        emit ChangedFeeSeller(feeSeller);
    }

    /**
     * @dev Set new address fee seller
     * @param _newAddressFee: new address fee seller
     */
    function setNewAddressFee(address _newAddressFee)
        public
        onlyRole(MANAGERMENT_ROLE)
    {
        addressReceiveFee = _newAddressFee;
        emit ChangedAddressReceiveSeller(addressReceiveFee);
    }

    function removeListSale(bytes32 orderId) internal {
        for (uint256 i = 0; i < listSale.length; i++) {
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
     * @param priceInWei: price in OAS
     * @param amount: Amount token
     */
    function createMarketItemSale(
        address contracAddress,
        uint256 tokenId,
        uint256 priceInWei,
        uint256 amount
    )
        public
        nonReentrant
        whenNotPaused
        returns (bytes32 orderId, address nftOwner)
    {
        uint256 timeNow = block.timestamp;
        (orderId, nftOwner) = _createMarketItemSale(
            contracAddress,
            tokenId,
            priceInWei,
            amount,
            timeNow
        );

        InfoItemSale memory newInfoItem = InfoItemSale(
            orderId,
            tokenId,
            msg.sender,
            priceInWei,
            amount,
            timeNow
        );
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
     * @param priceInWei: price in OAS
     * @param amount: Amount token
     * @param timeNow: Time Now
     */
    function _createMarketItemSale(
        address contractAddress,
        uint256 tokenId,
        uint256 priceInWei,
        uint256 amount,
        uint256 timeNow
    ) internal returns (bytes32, address) {
        // Transfer NFT to the marketplace
        if (isERC721(contractAddress)) {
            IERC721 nftContract = IERC721(contractAddress);
            address nftOwner = nftContract.ownerOf(tokenId);
            require(
                nftOwner == msg.sender,
                "ReMonsterMarketplace::createMarketItemSale: Only the owner can create orders"
            );
            require(
                nftContract.getApproved(tokenId) == address(this) ||
                    nftContract.isApprovedForAll(nftOwner, address(this)),
                "ReMonsterMarketplace::createMarketItemSale: The contract is not authorized to manage the asset"
            );
            require(
                priceInWei > 0,
                "ReMonsterMarketplace::createMarketItemSale: Price should be bigger than 0"
            );

            bytes32 orderId = keccak256(
                abi.encodePacked(
                    timeNow,
                    nftOwner,
                    tokenId,
                    contractAddress,
                    priceInWei
                )
            );

            orderByAssetId[orderId] = Order({
                contractAddress: contractAddress,
                tokenId: tokenId,
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
                "ReMonsterMarketplace::createMarketItemSale: Insufficient balance"
            );
            require(
                nftContract.isApprovedForAll(msg.sender, address(this)),
                "ReMonsterMarketplace::createMarketItemSale: The contract is not authorized to manage the asset"
            );
            require(
                priceInWei > 0,
                "ReMonsterMarketplace::createMarketItemSale: Price should be bigger than 0"
            );

            bytes32 orderId = keccak256(
                abi.encodePacked(
                    timeNow,
                    msg.sender,
                    tokenId,
                    contractAddress,
                    priceInWei,
                    amount
                )
            );
            // mo shi wa ke go dai ma se de shi ka

            orderByAssetId[orderId] = Order({
                contractAddress: contractAddress,
                tokenId: tokenId,
                active: true,
                seller: msg.sender,
                price: priceInWei,
                amount: amount
            });

            return (orderId, msg.sender);
        } else {
            revert(
                "ReMonsterMarketplace::createMarketItemSale: Unsupported contract"
            );
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
     * @param orderId - ID of the published NFT
     */

    function cancelMarketItemSale(bytes32 orderId)
        public
        nonReentrant
        whenNotPaused
    {
        _cancelMarketItemSale(orderId);
        removeListSale(orderId);
    }

    /**
     * @dev Cancel an already published market item
     *  can only be canceled by seller or the contract owner
     * @param orderId - ID of the published NFT
     */
    function _cancelMarketItemSale(bytes32 orderId)
        internal
        returns (Order memory order)
    {
        order = orderByAssetId[orderId];
        require(
            order.active,
            "ReMonsterMarketplace::cancelMarketItemSale: Asset not published"
        );
        require(
            order.seller == msg.sender || msg.sender == owner(),
            "ReMonsterMarketplace::cancelMarketItemSale: Unauthorized user"
        );

        address orderSeller = order.seller;
        delete orderByAssetId[orderId];
        emit OrderCancelled(
            orderId,
            order.tokenId,
            orderSeller,
            order.contractAddress
        );
    }

    /**
     * @dev Buy item directly from a published NFT
     * @param orderId - The NFT registry
     */
    function buyItem(bytes32 orderId)
        public
        payable
        nonReentrant
        whenNotPaused
    {
        Order memory order = orderByAssetId[orderId];
        require(
            order.active,
            "ReMonsterMarketplace::buyItem: Asset not published"
        );

        address seller = order.seller;

        require(
            seller != address(0),
            "ReMonsterMarketplace::buyItem: Invalid address"
        );
        require(
            seller != msg.sender,
            "ReMonsterMarketplace::buyItem: Unauthorized user"
        );
        require(order.price == msg.value, "ReMonsterMarketplace::buyItem: The price is not correct");

        if (isERC721(order.contractAddress)) {
            IERC721 nftContract = IERC721(order.contractAddress);
            require(
                seller == nftContract.ownerOf(order.tokenId),
                "ReMonsterMarketplace::buyItem: The seller is no longer the owner"
            );

            // Transfer asset owner
            nftContract.safeTransferFrom(seller, msg.sender, order.tokenId);
        } else if (isERC1155(order.contractAddress)) {
            IERC1155 nftContract = IERC1155(order.contractAddress);
            // Transfer asset owner
            nftContract.safeTransferFrom(
                seller,
                msg.sender,
                order.tokenId,
                order.amount,
                ""
            );
        } else {
            revert("ReMonsterMarketplace::buyItem: Unsupported contract");
        }

        uint256 saleShareAmount = 0;

        if (feeSeller > 0) {
            // Calculate sale share
            saleShareAmount = order.price.mul(feeSeller).div(
                100 * 10**decimalsFee
            );

            // Transfer share amount for marketplace Owner
            require(
                payable(addressReceiveFee).send(saleShareAmount),
                "ReMonsterMarketplace::buyItem: Transfering the cut to the Marketplace owner failed"
            );
        }

        // Transfer sale amount to seller
        require(
            payable(seller).send(order.price.sub(saleShareAmount)),
            "ReMonsterMarketplace::buyItem: Transfering the cut to the Marketplace owner failed"
        );

        delete orderByAssetId[orderId];
        removeListSale(orderId);

        emit OrderSuccessful(
            orderId,
            order.tokenId,
            seller,
            order.contractAddress,
            order.price,
            msg.sender
        );
    }

    function getListSale() public view returns (InfoItemSale[] memory) {
        return listSale;
    }

    function getInfoSaleByAddress(address seller)
        public
        view
        returns (InfoItemSale memory result)
    {
        for (uint256 i = 0; i < listSale.length; i++) {
            if (listSale[i].seller == seller) {
                result = listSale[i];
            }
        }
    }
}
