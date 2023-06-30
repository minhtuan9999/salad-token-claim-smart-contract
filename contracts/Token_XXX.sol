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
    address public validator;
    IERC20 public tokenBase;

    mapping(address => mapping(bytes => bool)) private usedSignature;

    event ChangeValidatorAddress(address validatorAddress);
    event MintToken(address account, uint256 amount);
    event BurnToken(address account, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        address addressTokenBase
    ) ERC20(name_, symbol_) {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, address(this));
        validator = _msgSender();
        // token init
        tokenBase = IERC20(addressTokenBase);
    }

    /**
     * @dev Change validator address
     * @param _validatorAddress  new validator address
     */
    function setValidator(address _validatorAddress)
        external
        onlyRole(ADMIN_ROLE)
    {
        // verify new exchange value
        validator = _validatorAddress;
        emit ChangeValidatorAddress(_validatorAddress);
    }

    function setTokenBase(IERC20 addressTokenBase) public onlyRole(ADMIN_ROLE) {
        tokenBase = addressTokenBase;
    }

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
        require(deadline > block.timestamp, "Deadline exceeded");
        require(!usedSignature[account][sig], "Used signature!");
        address signer = recoverData(
            typeBuy,
            block.chainid,
            account,
            amountInWei,
            ratio,
            deadline,
            sig
        );
        require(signer == validator, "Validator fail signature");
        uint256 totalPrice = amountInWei.mul(ratio).div(10**18);

        // Transfer amount for Owner
        require(
            tokenBase.transferFrom(account, address(this), totalPrice),
            "Transfering the cut to the owner failed"
        );
        // _mint(account, amountInWei);
        this.mintToken(account, amountInWei);
    }

    function mintToken(address _address, uint256 _amount) public onlyRole(ADMIN_ROLE){
        _mint(_address, _amount);
    }

    function burnToken(address account, uint256 amount)
        public
        whenNotPaused
        onlyRole(ADMIN_ROLE)
    {
        _burn(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override onlyRole(ADMIN_ROLE) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
