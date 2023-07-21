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
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface GenesisBox {
    function createNFT(address _address, uint256 _type) external;
}

interface GeneralBox {
    function createNFT(address _address, uint256 _type) external;
}

interface FarmNFT {
    function createNFT(address _address, uint256 _type) external;
}

contract ReMonsterShop is Ownable, ReentrancyGuard, AccessControl, Pausable {
    GenesisBox genesisContract;
    GeneralBox generalContract;
    FarmNFT farmContract;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    address payable public treasuryAddress;
    address public validator;

    uint256 public generalPrice = 30;
    uint256 public genesisPrice = 100;
    uint256 public farmPrice = 80;
    uint256 public bitPrice = 5;

    mapping(bytes => bool) public _isSigned;

    enum TypeAsset {
        GENERAL_BOX,
        GENESIS_BOX,
        FARM_NFT,
        BIT
    }
    event BuyAssetSuccessful(
        address owner,
        TypeAsset _type
    );
    event ChangedAddressReceive(address _treasuryAddress);

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param _addressReceice - Recipient address
     */
    constructor(address _addressReceice) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        // set Treasury Address
        setTreasuryAddress(payable(_addressReceice));
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // set General Contract
    function setGeneralContract(
        GeneralBox _generalContract
    ) external onlyRole(MANAGERMENT_ROLE) {
        generalContract = _generalContract;
    }

    // set Genesis Contract
    function setGenesisContract(
        GenesisBox _genesisContract
    ) external onlyRole(MANAGERMENT_ROLE) {
        genesisContract = _genesisContract;
    }
    // set Farm Contract
    function setFarmNFT(
        FarmNFT _farmContract
    ) external onlyRole(MANAGERMENT_ROLE) {
        farmContract = _farmContract;
    }

    /**
     * @dev Set new address
     * @param _newAddress: new address
     */
    function setTreasuryAddress(
        address _newAddress
    ) public onlyRole(MANAGERMENT_ROLE) {
        treasuryAddress = payable(_newAddress);
        emit ChangedAddressReceive(treasuryAddress);
    }

    function _buyItem(TypeAsset _type, uint256 _group, uint256 _number) private{
        if(_type == TypeAsset.GENERAL_BOX) {
            for(uint256 i=0; i < _number; i++) {
                generalContract.createNFT(msg.sender, _group);
            }
        } else if(_type == TypeAsset.GENESIS_BOX) {
            for(uint256 i=0; i < _number; i++) {
                genesisContract.createNFT(msg.sender, _group);
            }
        } else if(_type == TypeAsset.FARM_NFT){
            for(uint256 i=0; i < _number; i++) {
                farmContract.createNFT(msg.sender, _group);
            }
        } else {
            revert(
                "ReMonsterShop::_buyItem: Unsupported type"
            );
        }
    }

    /**
     * @dev Creates a new market item.
     * @param _type: type asset
     * @param _account: account buyer
     * @param _price: price of nft
     * @param _number: number of nft
     * @param _deadline: deadline signature
     * @param _sig: signature
     */
    function buyItem(
        TypeAsset _type,
        address _account,
        uint256 _group,
        uint256 _price,
        uint256 _number,
        uint256 _deadline,
        bytes calldata _sig
    ) public payable nonReentrant whenNotPaused {
        require(
            _deadline > block.timestamp,
            "ReMonsterShop::buyItem: Deadline exceeded"
        );
        require(
            !_isSigned[_sig],
            "ReMonsterShop::buyItem: Signature used"
        );
        require(_account == msg.sender, "ReMonsterShop::buyItem: wrong account");
        address signer = recoverOAS(
            _type,
            _account,
            _group,
            _price,
            _number,
            block.chainid,
            _deadline,
            _sig
        );
        require(
            signer == validator,
            "ReMonsterShop::buyItem: Validator fail signature"
        );
        require(
            msg.value == _price,
            "ReMonsterShop::buyItem: wrong msg value"
        );
        bool sent = treasuryAddress.send(_price);
        require(
            sent,
            "ReMonsterShop::buyItem: Failed to send Ether"
        );
        if (_type != TypeAsset.BIT) {
            _buyItem(_type, _group, _number);
        }
        emit BuyAssetSuccessful(msg.sender, _type);
    }

    /*
     * encode data
     * @param _type: type NFT
     * @param cost: fee
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     */
    function encodeOAS(
        TypeAsset _type,
        address _account,
        uint256 _group,
        uint256 _price,
        uint256 _number,
        uint256 _chainId,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return
            keccak256(abi.encode(_type, _account, _group, _price, _number, _chainId, _deadline));
    }

    /*
     * recover data
     * @param _type: type NFT
     * @param cost: fee
     * @param tokenId: tokenId of nft
     * @param chainId: chainId mint NFT
     * @param deadline: deadline using signature
     * @param signature: signature encode data
     */
    function recoverOAS(
        TypeAsset _type,
        address _account,
        uint256 _group,
        uint256 _price,
        uint256 _number,
        uint256 _chainId,
        uint256 _deadline,
        bytes calldata signature
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeOAS(_type, _account, _group, _price, _number, _chainId, _deadline)
                ),
                signature
            );
    }
}
