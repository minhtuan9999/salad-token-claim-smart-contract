// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenXXX is ERC20, AccessControl, Pausable {
    using SafeMath for uint256;

    // type 0: OAS
    // type 1: FIAT
    enum TypeBuy {
        OAS,
        FIAT
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    address public validator;
    // IERC20 public tokenBase;

    mapping(address => mapping(bytes => bool)) private usedSignature;

    event ChangeValidatorAddress(address validatorAddress);
    event BuyToken(TypeBuy typeBuy, address account, uint256 amount);
    event BurnToken(address account, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();
        // token init
        // tokenBase = IERC20(addressTokenBase);

        _mint(msg.sender, 10000);

    }

    /**
     * @dev Change validator address
     * @param _validatorAddress  new validator address
     */
    function setValidator(address _validatorAddress)
        external
        onlyRole(MANAGEMENT_ROLE)
    {
        // verify new exchange value
        validator = _validatorAddress;
        emit ChangeValidatorAddress(_validatorAddress);
    }

    // function setTokenBase(IERC20 addressTokenBase) public onlyRole(MANAGEMENT_ROLE) {
    //     tokenBase = addressTokenBase;
    // }

    function encodeData(
        TypeBuy typeBuy,
        uint256 chainId,
        address account,
        uint256 amountInWei,
        uint256 ratio,
        uint256 deadline
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeBuy,
                    chainId,
                    account,
                    amountInWei,
                    ratio,
                    deadline
                )
            );
    }

    function recoverData(
        TypeBuy typeBuy,
        uint256 chainId,
        address account,
        uint256 amountInWei,
        uint256 ratio,
        uint256 deadline,
        bytes calldata sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeData(
                        typeBuy,
                        chainId,
                        account,
                        amountInWei,
                        ratio,
                        deadline
                    )
                ),
                sig
            );
    }

    function buyToken(
        TypeBuy typeBuy,
        address account,
        uint256 amountInWei,
        uint256 ratio,
        uint256 deadline,
        bytes calldata sig
    ) public whenNotPaused {
        require(
            deadline > block.timestamp,
            "TokenXXX::buyToken: Deadline exceeded"
        );
        require(
            !usedSignature[account][sig],
            "TokenXXX::buyToken: Used signature!"
        );
        address signer = recoverData(
            typeBuy,
            block.chainid,
            account,
            amountInWei,
            ratio,
            deadline,
            sig
        );
        require(
            signer == validator,
            "TokenXXX::buyToken: Validator fail signature"
        );

        if (typeBuy == TypeBuy.OAS) {
            uint256 totalPrice = amountInWei.mul(ratio).div(10**18);

            // Transfer amount for Owner
            // require(
            //     tokenBase.transferFrom(account, address(this), totalPrice),
            //     "TokenXXX::buyToken: Transfering the cut to the owner failed"
            // );
            usedSignature[account][sig] = true;
            _mint(account, amountInWei);
        } else if (typeBuy == TypeBuy.FIAT) {
            usedSignature[account][sig] = true;
            _mint(account, amountInWei);
        } else {
            revert("TokenXXX::buyToken: Unsupported typeBuy");
        }
        emit BuyToken(typeBuy, account, amountInWei);
    }

    function burnToken(address account, uint256 amount)
        public
        whenNotPaused
        onlyRole(MANAGEMENT_ROLE)
    {
        _burn(account, amount);
        emit BurnToken(account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override onlyRole(ADMIN_ROLE) {
        super._transfer(from, to, amount);
    }

    /**
     * Withdraw all ERC-20 token base balance of this contract
     */
    function withdrawToken(address tokenAddress) external onlyRole(ADMIN_ROLE) {
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(msg.sender, balance);
    }
}
