//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ClaimSystem is AccessControl, Ownable {
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");
    IERC20 tokenBase;
    address public validator;

        struct UserInfor {
        uint256 total;
        uint256 claimed;
    }


    event ChangeValidatorAddress(address validatorAddress);
    event ClaimToken(
        address to,
        uint256 amount,
        address tokenAddress,
        bytes signature
    );

    mapping(address => uint256) deadlineTimeWithAddressClaim;
    mapping(address => UserInfor) public userInfor;

    constructor(IERC20 _tokenBase) {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();
        tokenBase = _tokenBase;
    }

    /**
     * @dev Change validator address
     * @param _validatorAddress  new validator address
     */
    function changeValidator(address _validatorAddress) external onlyOwner {
        // verify new exchange value
        validator = _validatorAddress;
        emit ChangeValidatorAddress(_validatorAddress);
    }

    function claimToken(
        address _address,
        uint256 _amount,
        uint256 deadline,
        bytes calldata sig
    ) external {
        require(_address == _msgSender(), "Unauthorized user");
        require(deadline > block.timestamp, "Deadline exceeded");
        require(
            deadlineTimeWithAddressClaim[_msgSender()] != deadline,
            "Transaction claimed"
        );

        address signer = recoverClaim(
            block.chainid,
            _msgSender(),
            _amount,
            deadline,
            sig
        );
        require(signer == validator, "Validator fail signature");

        require(
            tokenBase.balanceOf(address(this)) >= _amount,
            "Insufficient token funds"
        );
        userInfor[_msgSender()].claimed += _amount;
        // transfer token to user
        tokenBase.transfer(_msgSender(), _amount);
        // set deadline map msgSender
        deadlineTimeWithAddressClaim[_msgSender()] = deadline;

        emit ClaimToken(_msgSender(), _amount, address(tokenBase), sig);
    }

    function recoverClaim(
        uint256 chainId,
        address receiver,
        uint256 amount,
        uint256 deadline,
        bytes calldata sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeClaim(chainId, receiver, amount, deadline)
                ),
                sig
            );
    }

    function encodeClaim(
        uint256 chainId,
        address receiver,
        uint256 amount,
        uint256 deadline
    ) public pure returns (bytes32) {
        bytes memory m = abi.encode(chainId, receiver, amount, deadline);

        return keccak256(m);
    }

    /**
     * @dev Emergency withdraw token out of this contract
     * @notice only contract owner can call this function, token receiver may difference
     * @param _tokenAddress   token address
     * @param _to   receiver address
     */
    function emergencyWithdraw(
        IERC20 _tokenAddress,
        address _to
    ) external onlyOwner {
        // Get token balance
        uint256 balance = _tokenAddress.balanceOf(address(this));

        // Transfer to receiver
        _tokenAddress.transfer(_to, balance);
    }
}
