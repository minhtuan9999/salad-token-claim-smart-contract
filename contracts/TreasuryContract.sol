// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IToken {
    function burnToken(address account, uint256 amount) external;
}
contract TreasuryContract is
    Ownable,
    AccessControl,
    Pausable,
    ReentrancyGuard
{   
    IToken public tokenBaseContract;
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    address public validator;
    uint256 decimal = 10**18;

    mapping(GuildType => uint256) public costType;
    mapping(bytes => bool) public _isSigned;

    enum RewardType {
        SECTOR_CYCLE,
        GUILD_MONTHLY,
        PERSONAL_WEEKLY,
        PERSONAL_CYCLE
    }
    enum GuildType {
        CREATE_GUILD,
        RENAME_GUILD
    }

    event rewardEvent(address from, RewardType _type );
    event setGuilds(address from, GuildType guild );

    constructor(IToken tokenBase){
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = msg.sender;
        tokenBaseContract = tokenBase;
        costType[GuildType.CREATE_GUILD] = 10;
        costType[GuildType.RENAME_GUILD] = 5;
    }

    function pause() public onlyRole(MANAGEMENT_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(MANAGEMENT_ROLE) {
        _unpause();
    }

    function setValidator(address _validator) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        validator = _validator;
    }
    
    function setCostGuild(uint256 _cost, GuildType _type) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        costType[_type] = _cost;
    }

    /*
     * set guild function
     * @param _type: type set guild
     * @param _isOAS: cost type
     * @param _cost: cost
     * @param _deadline: deadline using signature
     * @param signature: signature
    */ 
    function setGuild(
        GuildType _type,
        address _account,
        bool _isOAS,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig
    ) external whenNotPaused nonReentrant payable {
        if (_isOAS) {
            require(
                _deadline > block.timestamp,
                "TreasuryContract::setGuild: Deadline exceeded"
            );
            require(
                !_isSigned[_sig],
                "TreasuryContract::setGuild: Signature used"
            );
            require(
                _account == msg.sender,
                "TreasuryContract::setGuild: wrong account"
            );
            address signer = recoverOAS(
                msg.sender,
                _cost,
                block.chainid,
                _deadline,
                _sig
            );
            require(
                signer == validator,
                "TreasuryContract::setGuild: Validator fail signature"
            );
            require(msg.value == _cost, "TreasuryContract::setGuild: wrong value");
        } else {
            tokenBaseContract.burnToken(msg.sender, (costType[_type])*decimal );
        }
        emit setGuilds(msg.sender, _type);
    }

    /*
     * reward function
     * @param _type: type reward
     * @param _totalAmount: amount reward
     * @param _deadline: deadline using signature
     * @param signature: signature
    */

    function reward(
        RewardType _type,
        address _account,
        uint256 _totalAmount,
        uint256 _deadline,
        bytes calldata _sig
    ) external whenNotPaused nonReentrant{
        require(
            _deadline > block.timestamp,
            "TreasuryContract::reward: Deadline exceeded"
        );
        require(
            !_isSigned[_sig],
            "TreasuryContract::reward: Signature used"
        );
        require(
            _account == msg.sender,
            "TreasuryContract::reward: wrong account"
        );
        address signer = recoverOAS(
            msg.sender,
            _totalAmount,
            block.chainid,
            _deadline,
            _sig
        );
        require(
            signer == validator,
            "TreasuryContract::reward: Validator fail signature"
        );
        
        bool sent = payable(msg.sender).send(_totalAmount);
        require(
            sent,
            "TreasuryContract::reward: Failed to send OAS"
        );
       
        emit rewardEvent(msg.sender, _type);
    }
    // Deposit OAS to treasury contract
    function deposit(uint256 totalAmount) external whenNotPaused nonReentrant payable{
        require(msg.value == totalAmount, "TreasuryContract::deposit: wrong value");
    }

    // Function to get the contract balance
    function getContractBalance() public onlyRole(MANAGEMENT_ROLE) view returns (uint256) {
        return address(this).balance;
    }

    // Function to withdraw by MANAGEMENT_ROLE
    function withdraw(uint256 amount) external whenNotPaused nonReentrant onlyRole(MANAGEMENT_ROLE) {
        bool sent = payable(msg.sender).send(amount);
        require(
            sent,
            "TreasuryContract::reward: Failed to claim OAS"
        );
    }


    /*
     * encode data
     * @param _type: type reward
     * @param _account: account reward
     * @param _totalAmount: amount reward
     * @param _chainId: chainId 
     * @param _deadline: deadline using signature
     */
    function encodeOAS(
        address _account,
        uint256 _totalAmount,
        uint256 _chainId,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _account,
                    _totalAmount,
                    _chainId,
                    _deadline
                )
            );
    }

    /*
     * recover data
     * @param _type: type reward
     * @param _account: account reward
     * @param _totalAmount: amount reward
     * @param _chainId: chainId 
     * @param _deadline: deadline using signature
     * @param signature: signature
    */
    function recoverOAS(
        address _account,
        uint256 _totalAmount,
        uint256 _chainId,
        uint256 _deadline,
        bytes calldata signature
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeOAS(
                    _account,
                    _totalAmount,
                    _chainId,
                    _deadline
                    )
                ),
                signature
            );
    }
    
}
