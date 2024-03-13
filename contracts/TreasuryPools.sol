// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TreasuryPoolsContract is
    Ownable,
    AccessControl,
    Pausable,
    ReentrancyGuard
{   
    using EnumerableSet for EnumerableSet.UintSet;
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    address public validator;
    uint256 decimal = 10**18;

    mapping(bytes => bool) public _isSigned;

    uint8 public totalPools;

    struct Pools {
        string name;
        uint256 amount;
        bool exists;
    }
    mapping (uint8 => Pools ) public pools;

    event rewardEvent(address from, uint8 rewardType );

    constructor(){
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = msg.sender;
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

    function addPool(string memory name) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        pools[totalPools].name = name;
        pools[totalPools].exists = true;
        totalPools++;
    }
    function deletePool(uint8 pool) external whenNotPaused onlyRole(MANAGEMENT_ROLE) {
        require(pools[pool].exists, "Pool does not exist");
        require(pools[pool].amount == 0, "Existing balance");
        delete pools[pool];
    }
    /*
     * reward function
     * @param _type: type reward
     * @param _totalAmount: amount reward
     * @param _deadline: deadline using signature
     * @param signature: signature
    */

    function reward(
        uint8 rewardType,
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
       
        emit rewardEvent(msg.sender, rewardType);
    }
    // Deposit OAS to treasury contract
    function deposit(uint256 totalAmount, uint8 _pool) external whenNotPaused nonReentrant payable{
        require(msg.value == totalAmount, "TreasuryContract::deposit: wrong value");
        require(pools[_pool].exists, "Pool does not exist");
        pools[_pool].amount +=totalAmount;
    }

    // Function to withdraw by MANAGEMENT_ROLE
    function withdraw(uint256 amount, uint8 _pool) external whenNotPaused nonReentrant onlyRole(MANAGEMENT_ROLE) {
        require(pools[_pool].exists, "Pool does not exist");
        require(amount <= pools[_pool].amount, "Insufficient ballance");
        bool sent = payable(msg.sender).send(amount);
        require(
            sent,
            "TreasuryContract::reward: Failed to claim OAS"
        );
        pools[_pool].amount -= amount ;
    }

    // Function to get the contract balance
    function getContractBalance() public view returns (uint256) {  
        return address(this).balance;
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
