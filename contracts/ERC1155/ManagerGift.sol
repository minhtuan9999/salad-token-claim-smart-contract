//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IItem {
    function mintMultipleItem(
        address _addressTo,
        uint256[] memory _itemId,
        uint256[] memory _number
    ) external;
}

contract ManagerGift is AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    IItem public contractTrainingItem;
    IItem public contractEnHanceItem;
    IItem public contractFusionItem;
    IItem public contractRegenerationItem;

    enum CollectionItem {
        TRAINING_ITEM,
        ENHANCE_ITEM,
        FUSION_ITEM,
        REGENERATION_ITEM
    }

    struct Gift {
        CollectionItem collectionItem;
        uint256[] typeItem;
        uint256[] amount;
    }

    constructor(
        IItem _contractTrainingItem,
        IItem _contractEnHanceItem,
        IItem _contractFusionItem,
        IItem _contractRegenerationItem
    ) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        contractTrainingItem = _contractTrainingItem;
        contractEnHanceItem = _contractEnHanceItem;
        contractFusionItem = _contractFusionItem;
        contractRegenerationItem = _contractRegenerationItem;
    }

    function setItems(
        IItem _contractTrainingItem,
        IItem _contractEnHanceItem,
        IItem _contractFusionItem,
        IItem _contractRegenerationItem
    ) external onlyRole(MANAGEMENT_ROLE) {
        contractTrainingItem = _contractTrainingItem;
        contractEnHanceItem = _contractEnHanceItem;
        contractFusionItem = _contractFusionItem;
        contractRegenerationItem = _contractRegenerationItem;
    }

    function giftItem(
        address[] memory _address,
        Gift[] memory _gift
    ) external onlyRole(MANAGEMENT_ROLE) {
        for (uint256 index = 0; index < _address.length; index++) {
            _giftItem(_address[index], _gift);
        }
    }

    function _giftItem(address _address, Gift[] memory _gift) internal virtual {
        for (uint256 index = 0; index < _gift.length; index++) {
            if (_gift[index].collectionItem == CollectionItem.TRAINING_ITEM) {
                _giftTrainingItem(_address, _gift[index].typeItem, _gift[index].amount);
            } else if (_gift[index].collectionItem == CollectionItem.ENHANCE_ITEM) {
                _giftEnhanceItem(_address, _gift[index].typeItem, _gift[index].amount);
            } else if (_gift[index].collectionItem == CollectionItem.FUSION_ITEM) {
                _giftFusionItem(_address, _gift[index].typeItem, _gift[index].amount);
            } else if (
                _gift[index].collectionItem == CollectionItem.REGENERATION_ITEM
            ) {
                _giftRegenerationItem(_address, _gift[index].typeItem, _gift[index].amount);
            } else {
                revert("ManagerGift::_giftItem: Unsupported collection");
            }
        }
    }

    function _giftTrainingItem(
        address _address,
        uint256[] memory _typeItem,
        uint256[] memory _amount
    ) internal virtual {
        require(
            _typeItem.length == _amount.length,
            "ManagerGift::_giftTrainingItem: Valid input"
        );
        contractTrainingItem.mintMultipleItem(_address, _typeItem, _amount);
    }

    function _giftEnhanceItem(
        address _address,
        uint256[] memory _typeItem,
        uint256[] memory _amount
    ) internal virtual {
        require(
            _typeItem.length == _amount.length,
            "ManagerGift::_giftEnhanceItem: Valid input"
        );
        contractEnHanceItem.mintMultipleItem(_address, _typeItem, _amount);
    }

    function _giftFusionItem(
        address _address,
        uint256[] memory _typeItem,
        uint256[] memory _amount
    ) internal virtual {
        require(
            _typeItem.length == _amount.length,
            "ManagerGift::_giftFusionItem: Valid input"
        );
        contractFusionItem.mintMultipleItem(_address, _typeItem, _amount);
    }

    function _giftRegenerationItem(
        address _address,
        uint256[] memory _typeItem,
        uint256[] memory _amount
    ) internal virtual {
        require(
            _typeItem.length == _amount.length,
            "ManagerGift::_giftRegenerationItem: Valid input"
        );
        contractRegenerationItem.mintMultipleItem(_address, _typeItem, _amount);
    }
}
