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
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface GenesisBox {
    // Detail of Group
    struct GroupDetail {
        uint256 totalSupply;
        uint256 issueAmount;
        uint256 issueMarketing;
        uint256[] limitType;
        uint256[] amountType;
    }

    function createBox(address _address, uint8 _type) external;

    function getDetailGroup(
        uint256 group
    ) external view returns (GroupDetail memory);
}

interface GeneralBox {
    // Detail of Group
    struct GroupDetail {
        uint256 totalSupply;
        uint256 issueAmount;
        uint256 issueMarketing;
        uint256[] limitType;
        uint256[] amountType;
    }

    function createBox(address _address, uint8 _type) external;

    function getDetailGroup(
        uint256 group
    ) external view returns (GroupDetail memory);
}

interface FarmNFT {
    function getTotalLimit() external view returns (uint256);

    function createNFT(address _address, uint256 _type) external;

    function totalSupply() external view returns (uint256);
}

contract ReMonsterShop is Ownable, ReentrancyGuard, AccessControl, Pausable {
    GenesisBox genesisContract;
    GeneralBox generalContract;
    FarmNFT farmContract;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGERMENT_ROLE = keccak256("MANAGERMENT_ROLE");

    address public treasuryAddress;
    address public validator;

    uint256 public generalPrice;
    uint256 public genesisPrice;
    uint256 public farmPrice;

    struct AssetSale {
        uint256 total;
        uint256 remaining;
        uint256[] price;
        GroupAsset[] detail;
    }

    struct GroupAsset {
        uint256 total;
        uint256 remaining;
    }

    struct PackageBit{
        uint256 priceOAS;
        uint256 priceBit;
    }

    mapping(bytes => bool) public _isSigned;
    mapping(uint256 => PackageBit) public packageBit;
    EnumerableSet.UintSet listBitPackage;
    enum TypeAsset {
        GENERAL_BOX,
        GENESIS_BOX,
        FARM_NFT,
        BIT
    }
    event BuyAssetSuccessful(address owner, TypeAsset _type, uint256 package);
    event ChangedAddressReceive(address _treasuryAddress);

    /**
     * @dev Initialize this contract. Acts as a constructor
     * @param _addressReceice - Recipient address
     */
    constructor(
        address _addressReceice,
        GeneralBox addressGeneral,
        GenesisBox addressGenesis,
        FarmNFT addressFarm,
        uint256 _generalPrice,
        uint256 _genesisPrice,
        uint256 _farmPrice,
        uint256 _bitPrice
    ) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MANAGERMENT_ROLE, MANAGERMENT_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(MANAGERMENT_ROLE, _msgSender());
        setTreasuryAddress(payable(_addressReceice));
        generalPrice = _generalPrice;
        genesisPrice = _genesisPrice;
        farmPrice = _farmPrice;
        generalContract = addressGeneral;
        genesisContract = addressGenesis;
        farmContract = addressFarm;
        validator = _msgSender();
        packageBit[0].priceOAS = _bitPrice;
        packageBit[0].priceBit = 10000;
        listBitPackage.add(0);
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // set Validator
    function setValidator(
        address _validator
    ) external onlyRole(MANAGERMENT_ROLE) {
        validator = _validator;
    }

    // set Price farm
    function setNewPriceFarm(
        uint256 newPrice
    ) external onlyRole(MANAGERMENT_ROLE) {
        farmPrice = newPrice;
    }

    // set Price Genesis
    function setNewPriceGenesis(
        uint256 newPrice
    ) external onlyRole(MANAGERMENT_ROLE) {
        genesisPrice = newPrice;
    }

    // set Price General
    function setNewPriceGeneral(
        uint256 newPrice
    ) external onlyRole(MANAGERMENT_ROLE) {
        generalPrice = newPrice;
    }

    // set Price BIT
    function setPricePackageBit(
        uint256 package,
        uint256 newOAS,
        uint256 newBit
    ) external onlyRole(MANAGERMENT_ROLE) {
        packageBit[package].priceOAS = newOAS;
        packageBit[package].priceBit = newBit;
        listBitPackage.add(package);
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
        treasuryAddress = _newAddress;
        emit ChangedAddressReceive(treasuryAddress);
    }

    /**
     * @dev get list package
     */
    function getListBitPackage() public view returns(uint256[] memory) {
        return listBitPackage.values();
    }

    function _buyItem(
        TypeAsset _type,
        uint8 _group,
        uint256 _number
    ) private {
        if (_type == TypeAsset.GENERAL_BOX) {
            uint256 remaining = generalContract.getDetailGroup(_group).totalSupply.sub(generalContract.getDetailGroup(_group).issueAmount);
            require(_number <= remaining, "ReMonsterShop::_buyItem: Exceeding");
            for (uint256 i = 0; i < _number; i++) {
                generalContract.createBox(msg.sender, _group);
            }
        } 
        else if (_type == TypeAsset.GENESIS_BOX) {
            uint256 remaining = genesisContract.getDetailGroup(_group).totalSupply.sub(genesisContract.getDetailGroup(_group).issueAmount);
            require(_number <= remaining, "ReMonsterShop::_buyItem: Exceeding");
            for (uint256 i = 0; i < _number; i++) {
                genesisContract.createBox(msg.sender, _group);
            }
        } else if (_type == TypeAsset.FARM_NFT) {
            uint256 remaining = farmContract.getTotalLimit().sub(
                farmContract.totalSupply()
            );
            require(_number <= remaining, "ReMonsterShop::_buyItem: Exceeding");
            for (uint256 i = 0; i < _number; i++) {
                farmContract.createNFT(msg.sender, _group);
            }
        } else {
            revert("ReMonsterShop::_buyItem: Unsupported type");
        }
    }

    /**
     * @dev Creates a new market item.
     */
    function buyItem(
        TypeAsset _type,
        address _account,
        uint256 _package,
        uint8 _group,
        uint256 _price,
        uint256 _number,
        uint256 _deadline,
        bytes calldata _sig
    ) public payable nonReentrant whenNotPaused {
        require(
            _deadline > block.timestamp,
            "ReMonsterShop::buyItem: Deadline exceeded"
        );
        require(!_isSigned[_sig], "ReMonsterShop::buyItem: Signature used");
        require(
            _account == msg.sender,
            "ReMonsterShop::buyItem: wrong account"
        );
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
        require(msg.value == _price, "ReMonsterShop::buyItem: wrong msg value");
        bool sent = payable(treasuryAddress).send(_price);
        require(sent, "ReMonsterShop::buyItem: Failed to send Ether");
        if (_type == TypeAsset.BIT) {
            require(packageBit[_package].priceOAS > 0, "Shop:: buyItem: package not found");
        }else {
            _buyItem(_type, _group, _number);
        }
        emit BuyAssetSuccessful(msg.sender, _type, _package);
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
            keccak256(
                abi.encode(
                    _type,
                    _account,
                    _group,
                    _price,
                    _number,
                    _chainId,
                    _deadline
                )
            );
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
                    encodeOAS(
                        _type,
                        _account,
                        _group,
                        _price,
                        _number,
                        _chainId,
                        _deadline
                    )
                ),
                signature
            );
    }

    function getListSale() external view returns (AssetSale[] memory) {
        AssetSale[] memory listSale = new AssetSale[](4);
        // Farm
        GroupAsset[] memory groupAssetFarm;
        listSale[0] = AssetSale(
            farmContract.getTotalLimit(),
            farmContract.getTotalLimit().sub(farmContract.totalSupply()),
            _asSingletonArrays(farmPrice),
            groupAssetFarm
        );
        
        // General
        GroupAsset[] memory groupAssetGeneral = new GroupAsset[](5);
        for (uint i = 0; i < 5; i++) {
            uint256 remaining = generalContract.getDetailGroup(i).totalSupply.sub(generalContract.getDetailGroup(i).issueAmount);
            groupAssetGeneral[i] = GroupAsset(
                generalContract.getDetailGroup(i).totalSupply,
                remaining
            );
        }
        listSale[1] = AssetSale(0, 0, _asSingletonArrays(generalPrice), groupAssetGeneral);

        // Genesis
        GroupAsset[] memory groupAssetGenesis  = new GroupAsset[](5);
        for (uint i = 0; i < 5; i++) {
            uint256 remaining = genesisContract.getDetailGroup(i).totalSupply.sub(genesisContract.getDetailGroup(i).issueAmount);
            groupAssetGenesis[i] = GroupAsset(
                genesisContract.getDetailGroup(i).totalSupply,
                remaining
            );
        }
        listSale[2] = AssetSale(0, 0, _asSingletonArrays(genesisPrice), groupAssetGenesis);

        // Bit
        GroupAsset[] memory groupAssetBit;
        uint256[] memory listBitPrice = new uint256[](listBitPackage.length());        
        for(uint i = 0 ; i < listBitPackage.length(); i++ ) {
            listBitPrice[i] = packageBit[listBitPackage.at(i)].priceOAS;
        }

        listSale[3] = AssetSale(0, 0, listBitPrice, groupAssetBit);
        return listSale;
    }

    /**
     * @dev Creates an array in memory with only one value for each of the elements provided.
     */
    function _asSingletonArrays(uint256 element)
        private
        pure
        returns (uint256[] memory array)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Load the free memory pointer
            array := mload(0x40)
            // Set array length to 1
            mstore(array, 1)
            // Store the single element at the next word after the length (where content starts)
            mstore(add(array, 0x20), element)

            // Update the free memory pointer by pointing after the array
            mstore(0x40, add(array, 0x40))
        }
    }

}
