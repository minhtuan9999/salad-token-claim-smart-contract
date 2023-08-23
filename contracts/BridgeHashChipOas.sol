// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IHashChipNFT {
    function createNFT(address _address, uint256 _tokenId) external;
}
interface IGenesisBox {
    function createBox(address _address,uint8 _type) external;
}
interface IFarmNFT {
    function createNFT(address _address,uint256 _type) external;
}
interface IFarmItem {
    function mintMultipleItem(address _addressTo,uint256[] memory _itemId,uint256[] memory _number) external;
}
contract Bridge is AccessControl, Pausable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    using EnumerableSet for EnumerableSet.UintSet;
    address public validator;

    uint256[] public permanentItemIds;
    uint256[] public permanentNumbers;

    IHashChipNFT hashChipAddress;
    IGenesisBox genesisAddress;
    IFarmNFT farmAddress;
    IFarmItem itemFarmAddress;

    mapping(bytes => bool) public _isSigned;
    mapping(address => EnumerableSet.UintSet) private  listTokenBridgeOfAddress;
    event BridgeNFT(address to, uint256 hashChipId);

    constructor(IHashChipNFT _hashChipAddress, IGenesisBox _genesisAddress, IFarmNFT _farmAddress, IFarmItem _itemFarmAddress) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();

        hashChipAddress = _hashChipAddress;
        genesisAddress = _genesisAddress;
        farmAddress = _farmAddress;
        itemFarmAddress = _itemFarmAddress;
        permanentItemIds = [54, 55];
        permanentNumbers = [1,1];
    }

    // Get list Tokens bridge of address
    function getListTokenBridgeOfAddress(
        address _address
    ) public view returns (uint256[] memory) {
        return listTokenBridgeOfAddress[_address].values();
    }

    // Set hashchip contract address
    function setHashChipAddress(
        IHashChipNFT _hashChipAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        hashChipAddress = _hashChipAddress;
    }

    // Set genesis contract address
    function setGenesisAddress(
        IGenesisBox _genesisAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        genesisAddress = _genesisAddress;
    }

    // Set farm contract address
    function setFarmAddress(
        IFarmNFT _farmAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        farmAddress = _farmAddress;
    }

    // Set item farm address
    function setItemFarmAddress(
        IFarmItem _itemFarmAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        itemFarmAddress = _itemFarmAddress;
    }

    // Set item farm claim
    function setItemFarmClaim(
        uint256[] memory listItem,
        uint256[] memory number
    ) external onlyRole(MANAGEMENT_ROLE) {
        require(listItem.length == number.length, "Bridge: Wrong input");
        permanentItemIds = listItem;
        permanentNumbers = number;
    }

    function encodeBridge(
        address to,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(to, tokenId, chainId, deadline));
    }

    function recoverBridge(
        address to,
        uint256 tokenId,
        uint256 chainId,
        uint256 deadline,
        bytes calldata sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeBridge(to, tokenId, chainId, deadline)
                ),
                sig
            );
    }
    /**
     * @dev Bridge NFT 
     * @param to: address bridge
     * @param tokenId: tokenId bridge
     * @param typeGenesis: type genesis box
     * @param typeFarm: type farm
     * @param deadline: deadline 
     * @param sig: signature
     * 
     */
    function bridgeNFT(
        address to,
        uint256 tokenId,
        uint8 typeGenesis,
        uint256 typeFarm,
        uint256 deadline,
        bytes calldata sig
    ) public whenNotPaused {
        require(
            deadline > block.timestamp,
            "Bridge::buyItem: Deadline exceeded"
        );
        require(!_isSigned[sig], "Bridge: Signature used");
        require(
            to == msg.sender,
            "Bridge: wrong account"
        );
        address signer = recoverBridge(
            to,
            tokenId,
            block.chainid,
            deadline,
            sig
        );
        require(
            signer == validator,
            "Bridge: Validator fail signature"
        );
        hashChipAddress.createNFT(to, tokenId);
        genesisAddress.createBox(to, typeGenesis);
        farmAddress.createNFT(to, typeFarm);
        itemFarmAddress.mintMultipleItem(to, permanentItemIds, permanentNumbers);
        listTokenBridgeOfAddress[to].add(tokenId);
        emit BridgeNFT(to, tokenId);
    }
}
