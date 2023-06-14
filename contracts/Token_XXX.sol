// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenXXX is AccessControl, Pausable {
    using SafeMath for uint256;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public validator;
    IERC20 public tokenBase;

    mapping(address => mapping(bytes => bool)) private usedSignature;
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    event ChangeValidatorAddress(address validatorAddress);
    event MintToken(address account, uint256 amount);
    event BurnToken(address account, uint256 amount);

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address addressTokenBase
    ) {
        _name = name_;
        _symbol = symbol_;
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _msgSender());
        validator = _msgSender();
        // token init
        tokenBase = IERC20(addressTokenBase);
    }

    /**
     * @dev Change validator address
     * @param _validatorAddress  new validator address
     */
    function setValidator(address _validatorAddress) external onlyRole(ADMIN_ROLE) {
        // verify new exchange value
        validator = _validatorAddress;
        emit ChangeValidatorAddress(_validatorAddress);
    }

    function setTokenBase(IERC20 addressTokenBase)
        public
        onlyRole(ADMIN_ROLE)
    {
        tokenBase = addressTokenBase;
    }

    function encodeData(
        uint256 chainId,
        address account,
        uint256 amount,
        uint256 rate,
        uint256 deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(chainId, account, amount, rate, deadline));
    }

    function recoverData(
        uint256 chainId,
        address account,
        uint256 amount,
        uint256 rate,
        uint256 deadline,
        bytes calldata sig
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeData(chainId, account, amount, rate, deadline)
                ),
                sig
            );
    }

    function buyTokenFromOAS(
        uint256 amount,
        uint256 rate,
        uint256 deadline,
        bytes calldata sig
    ) public whenNotPaused {
        require(deadline > block.timestamp, "Deadline exceeded");
        require(!usedSignature[msg.sender][sig], "Used signature!");
        address signer = recoverData(
            block.chainid,
            msg.sender,
            amount,
            rate,
            deadline,
            sig
        );
        require(signer == validator, "Validator fail signature");
        uint256 totalPrice = amount.mul(rate);

        // Transfer amount for Owner
        require(
            tokenBase.transferFrom(msg.sender, address(this), totalPrice),
            "Transfering the cut to the owner failed"
        );
        _mint(msg.sender, amount);
    }

    function buyTokenFromFiat(
        address account,
        uint256 amount
    ) public whenNotPaused onlyRole(ADMIN_ROLE) {
        _mint(account, amount);
    }

    function burnToken(address account, uint256 amount)
        public
        whenNotPaused
        onlyRole(ADMIN_ROLE)
    {
        _burn(account, amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit MintToken(account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit BurnToken(account, amount);
    }
}
