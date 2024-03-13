// // SPDX-License-Identifier: CC0-1.0
// pragma solidity ^0.8.18;

// // import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// // import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// // import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "./ERC721/Farm.sol";

// contract RentalFarm is Ownable, AccessControl {
//     using SafeMath for uint256;

//     bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
//     bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

//     IERC20 public tokenBase;
//     ReMonsterFarm public immutable farmContract;

//     struct RentalListing {
//         bool isListing;
//         address owner;
//         uint256 pricePerSecond;
//     }

//     // Token ID => RentalListing
//     mapping(uint256 => RentalListing) public infoFarm;

//     constructor(address admin, address manager, ReMonsterFarm farm, IERC20 _tokenBase) {
//         _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
//         _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
//         _setupRole(ADMIN_ROLE, admin);
//         _setupRole(MANAGERMENT_ROLE, manager);
//         farmContract = farm;
//         tokenBase = _tokenBase;
//     }

//     function rentalListing(uint256 tokenId, uint256 pricePerSecond) public {
//         address nftOwner = farmContract.ownerOf(tokenId);
//         require(nftOwner == msg.sender, "Only the owner can lease Farm");
//         require(
//             farmContract.getApproved(tokenId) == address(this) ||
//                 farmContract.isApprovedForAll(nftOwner, address(this)),
//             "The contract is not authorized to manage the asset"
//         );
//         // tokenId must be approved for this contract
//         farmContract.transferFrom(msg.sender, address(this), tokenId);
//         infoFarm[tokenId] = RentalListing({
//             isListing: true,
//             owner: nftOwner,
//             pricePerSecond: pricePerSecond
//         });
//     }

//     function redeemFarm(uint256 tokenId) public {
//         address nftOwner = infoFarm[tokenId].owner;
//         require(infoFarm[tokenId].isListing, "Lease farm does not exist");
//         require(nftOwner == msg.sender, "Only the owner can end lease Farm");
//         require(farmContract.userOf(tokenId) == address(0), "Error.....");

//         farmContract.transferFrom(address(this), msg.sender, tokenId);
//         delete infoFarm[tokenId];
//     }

//     function leaseFarm(uint256 tokenId, uint256 time) public {
//         require(infoFarm[tokenId].isListing, "Lease farm does not exist");
//         require(farmContract.userOf(tokenId) == address(0), "Error.....");

//         address nftOwner = infoFarm[tokenId].owner;
//         uint256 total = infoFarm[tokenId].pricePerSecond.mul(time);
//         require(
//             tokenBase.transferFrom(msg.sender, address(this), total),
//             "Transfering the cut to the Rental owner failed"
//         );
//         require(
//             tokenBase.transferFrom(address(this), nftOwner, total),
//             "Transfering the cut to the Rental owner failed"
//         );
//     }
// }
