// Sources flattened with hardhat v2.19.4 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/access/IAccessControl.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// File @openzeppelin/contracts/utils/Context.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File @openzeppelin/contracts/utils/math/Math.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // ΓåÆ `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // ΓåÆ `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = sqrt(a);
            return
                result +
                (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log2(value);
            return
                result +
                (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log10(value);
            return
                result +
                (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            uint256 result = log256(value);
            return
                result +
                (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// File @openzeppelin/contracts/utils/math/SignedMath.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File @openzeppelin/contracts/utils/Strings.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toString(int256 value) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    value < 0 ? "-" : "",
                    toString(SignedMath.abs(value))
                )
            );
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File @openzeppelin/contracts/access/AccessControl.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```solidity
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```solidity
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it. We recommend using {AccessControlDefaultAdminRules}
 * to enforce additional security measures for this role.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role)
        public
        view
        virtual
        override
        returns (bytes32)
    {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
    {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
    {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account)
        public
        virtual
        override
    {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File @openzeppelin/contracts/token/ERC1155/IERC1155.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// File @openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// File @openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// File @openzeppelin/contracts/utils/Address.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File @openzeppelin/contracts/utils/cryptography/ECDSA.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs &
            bytes32(
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ├╖ 2 + 1, and for v in (302): v Γêê {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32 message)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(s.length),
                    s
                )
            );
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32 data)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }

    /**
     * @dev Returns an Ethereum Signed Data with intended validator, created from a
     * `validator` and `data` according to the version 0 of EIP-191.
     *
     * See {recover}.
     */
    function toDataWithIntendedValidatorHash(
        address validator,
        bytes memory data
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File contracts/ERC721/Monster/RegenAndFusionMonster.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IGeneralHash {
    function burn(uint256 _tokenId) external;

    function setTimesOfRegeneration(
        uint256 season,
        uint256 tokenId,
        uint256 times
    ) external;

    function _numberOfRegenerations(uint256 season, uint256 tokenId)
        external
        view
        returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IGenesisHash is IGeneralHash {
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IHashChip {
    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external;

    function setTimesOfRegeneration(
        uint256 season,
        uint256 tokenId,
        uint256 times
    ) external;

    function _numberOfRegenerations(uint256 season, uint256 tokenId)
        external
        view
        returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

interface IToken {
    function burnToken(address account, uint256 amount) external;
}

interface IMonsterMemory {
    function mint(address _address, uint256 _monsterId) external;
}

interface IRegenerationItem {
    function burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) external;

    function burnMultipleItem(
        address _from,
        uint256[] memory _id,
        uint256[] memory _amount
    ) external;

    function isMintMonster(uint256 _itemId) external view returns (bool);
}

interface IFusionItem is IRegenerationItem {}

interface IMonsterContract {
    function mintMonster(
        address _address,
        uint8 _type,
        bool _isMonsterFree
    ) external returns (uint256);

    function getStatusMonster(uint256 _tokenId) external view returns (bool);

    function burn(uint256 _tokenId) external;

    function isFreeMonster(uint256 _tokenId) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract RegenFusionMonster is Ownable, AccessControl, ReentrancyGuard {
    IToken public tokenBaseContract;
    IGenesisHash public genesisHashContract;
    IGeneralHash public generalHashContract;
    IHashChip public hashChipNFTContract;
    IMonsterMemory public monsterMemory;
    IRegenerationItem public regenerationItem;
    IFusionItem public fusionItem;
    IMonsterContract public monsterContract;

    bytes32 public constant MANAGEMENT_ROLE = keccak256("MANAGEMENT_ROLE");

    // Season
    uint8 public season;
    // Validator
    address public validator;
    // Address receive fee
    address receiveFee;
    // Decimal
    uint8 public DECIMAL = 10 ^ 18;
    // Status signature
    mapping(bytes => bool) public _isSigned;

    enum TypeMint {
        NFT,
        COLLABORATION_NFT,
        FREE,
        GENESIS_HASH,
        GENERAL_HASH,
        HASH_CHIP_NFT,
        REGENERATION_ITEM,
        FUSION_GENESIS_HASH,
        FUSION_MULTIPLE_HASH,
        FUSION_GENERAL_HASH,
        FUSION_MONSTER
    }

    enum CostMint {
        OAS,
        XXX,
        TICKET,
        FREE
    }

    struct MintParams {
        TypeMint typeMint;
        address addressContract;
        uint8 chainId;
        address account;
        uint256[] tokenIds;
        CostMint usingCost;
        uint256 cost;
        uint256 deadline;
        bytes sig;
        uint8[] seed;
        uint8[] ticketIds;
        uint8[] ticketAmounts;
        uint256[] itemFusionIds;
        uint256[] itemFusionAmounts;
        uint8 monsterIdGame;
    }

    // Costs and Limits
    uint8[] public costOfGenesis = [8, 9, 10, 11, 12];
    uint8[] public costOfGeneral = [8, 10, 12];
    uint8[] public costOfNfts = [8, 10, 12];
    uint8[] public costOfExternal = [8, 10, 12];
    uint8[] public costOfHashChip = [8, 10, 12];

    uint8[6] public limits = [3, 3, 0, 5, 3, 3];

    uint8 public nftRepair = 10;

    uint8 REGENERATION_TICKET_R = 6;
    uint8 REGENERATION_TICKET_B = 7;
    mapping(uint8 => bool) public usingTicket;

    event FusionMonsterNFT(
        address owner,
        uint256 newMonster,
        uint256[] tokenIds,
        uint8[] seeds,
        address monsterAddress,
        uint8 monsterIdGame
    );

    event FusionGenesisHash(
        address owner,
        uint256[] tokenIds,
        uint256 newTokenId,
        uint8[] seeds,
        address monsterAddress,
        uint8 monsterIdGame
    );

    event FusionGeneralHash(
        address owner,
        uint256[] tokenIds,
        uint256 newTokenId,
        uint8[] seeds,
        address monsterAddress,
        uint8 monsterIdGame
    );

    event FusionMultipleHash(
        address owner,
        uint256[] tokenIds,
        uint256 newTokenId,
        uint8[] seeds,
        address genesisAddress,
        address generalAddress,
        uint8 monsterIdGame
    );

    event RefreshTimesRegeneration(uint8 _type, uint256 tokenId);

    event RegenerationFromGenesisHash(
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        uint256 tokenId,
        address hashAddress,
        uint8 monsterIdGame
    );
    event RegenerationFromGeneralHash(
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        uint256 tokenId,
        address hashAddress,
        uint8 monsterIdGame
    );
    event RegenerationFromHashChip(
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        uint256 tokenId,
        address hashAddress,
        uint8 monsterIdGame
    );
    event RegenerationFromExternalNFT(
        uint8 _type,
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        address bornAddress,
        uint256 bornId,
        uint256 chainId,
        uint8 monsterIdGame
    );
    event RegenerationFromItems(
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        uint8 itemId,
        address itemAddress,
        uint8 monsterIdGame
    );

    event RegenerationFreeMonster(
        address owner,
        uint256 monsterId,
        uint8[] seeds,
        uint8 monsterIdGame
    );

    // Check status mint nft free of address
    mapping(address => bool) public _realdyFreeNFT;
    //  =>( TypeMint => chainId => (contractAddress => (tokenId => number Of Regenerations)))
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(uint256 => uint256))))
        public _timesRegenExternal;

    // Set contract addresses
    function initContractAddress(
        IToken _tokenBase,
        IGeneralHash _generalHash,
        IGenesisHash _genesisHash,
        IHashChip _hashChip,
        IMonsterMemory _monsterMemory,
        IRegenerationItem _regenerationItem,
        IFusionItem _fusionItem,
        IMonsterContract _monsterContract,
        address receiveFreeAddress
    ) external onlyRole(MANAGEMENT_ROLE) {
        tokenBaseContract = _tokenBase;
        generalHashContract = _generalHash;
        genesisHashContract = _genesisHash;
        hashChipNFTContract = _hashChip;
        monsterMemory = _monsterMemory;
        regenerationItem = _regenerationItem;
        fusionItem = _fusionItem;
        monsterContract = _monsterContract;
        receiveFee = receiveFreeAddress;
        usingTicket[REGENERATION_TICKET_B] = true;
        usingTicket[REGENERATION_TICKET_R] = true;
    }

    constructor() {
        _setRoleAdmin(MANAGEMENT_ROLE, MANAGEMENT_ROLE);
        _setupRole(MANAGEMENT_ROLE, _msgSender());
        validator = _msgSender();
    }

    function setValidator(address _address) external onlyOwner {
        validator = _address;
    }

    // set new season
    function setNewSeason() external onlyRole(MANAGEMENT_ROLE) {
        season++;
    }

    // set fee repair nft
    function setNftRepair(uint8 _cost) external onlyRole(MANAGEMENT_ROLE) {
        nftRepair = _cost;
    }

    // set cost for type
    function setCostOfType(TypeMint _typeMint, uint8[] memory cost)
        external
        onlyRole(MANAGEMENT_ROLE)
    {
        require(limits[uint8(_typeMint)] > 0, "Unsupported type");
        if (_typeMint == TypeMint.GENERAL_HASH) costOfGeneral = cost;
        else if (_typeMint == TypeMint.GENESIS_HASH) costOfGenesis = cost;
        else if (_typeMint == TypeMint.NFT) costOfNfts = cost;
        else if (_typeMint == TypeMint.COLLABORATION_NFT) costOfExternal = cost;
        else if (_typeMint == TypeMint.HASH_CHIP_NFT) costOfHashChip = cost;
    }

    // set limit for type
    function setLimitOfType(TypeMint _typeMint, uint8 limit)
        external
        onlyRole(MANAGEMENT_ROLE)
    {
        limits[uint8(_typeMint)] = limit;
    }

    function _fromGeneralHash(
        address _address,
        uint256 _tokenId,
        uint8[] memory seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            generalHashContract._numberOfRegenerations(season, _tokenId) <
                limits[uint8(TypeMint.GENERAL_HASH)],
            "Times limit"
        );
        require(
            IERC721(address(generalHashContract)).ownerOf(_tokenId) == _address,
            "Wrong owner"
        );
        generalHashContract.setTimesOfRegeneration(
            season,
            _tokenId,
            generalHashContract._numberOfRegenerations(season, _tokenId) + 1
        );
        if (
            generalHashContract._numberOfRegenerations(season, _tokenId) + 1 ==
            limits[uint8(TypeMint.GENERAL_HASH)]
        ) {
            generalHashContract.burn(_tokenId);
        }
        emit RegenerationFromGeneralHash(
            _address,
            monsterContract.mintMonster(
                _address,
                uint8(TypeMint.GENERAL_HASH),
                false
            ),
            seeds,
            _tokenId,
            address(generalHashContract),
            _monsterIdGame
        );
    }

    function _fromGenesisHash(
        address _address,
        uint256 _tokenId,
        uint8[] memory seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            genesisHashContract._numberOfRegenerations(season, _tokenId) <
                limits[uint8(TypeMint.GENESIS_HASH)],
            "Times limit"
        );
        require(
            genesisHashContract.ownerOf(_tokenId) == _address,
            "Wrong owner"
        );
        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenId,
            genesisHashContract._numberOfRegenerations(season, _tokenId) + 1
        );

        emit RegenerationFromGenesisHash(
            _address,
            monsterContract.mintMonster(
                _address,
                uint8(TypeMint.GENESIS_HASH),
                false
            ),
            seeds,
            _tokenId,
            address(genesisHashContract),
            _monsterIdGame
        );
    }

    function _fromExternalNFT(
        address _address,
        TypeMint _typeMint,
        uint256 _chainId,
        address _addressContract,
        uint256 _tokenId,
        uint8[] memory seeds,
        uint8 _monsterIdGame
    ) private {
        if (isERC721(_addressContract)) {
            require(
                IERC721(_addressContract).ownerOf(_tokenId) == _address,
                "Wrong owner"
            );
        } else if (isERC1155(_addressContract)) {
            require(
                IERC1155(_addressContract).balanceOf(_address, _tokenId) > 0,
                "Balance not enough"
            );
        }
        require(
            _timesRegenExternal[season][_chainId][_addressContract][_tokenId] <
                limits[uint256(_typeMint)],
            "Times limit"
        );
        _timesRegenExternal[season][_chainId][_addressContract][_tokenId]++;
        emit RegenerationFromExternalNFT(
            uint8(_typeMint),
            _address,
            monsterContract.mintMonster(_address, uint8(_typeMint), false),
            seeds,
            _addressContract,
            _tokenId,
            _chainId,
            _monsterIdGame
        );
    }

    function _fromHashChipNFT(
        address _address,
        uint256 _tokenId,
        uint8[] memory seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            hashChipNFTContract._numberOfRegenerations(season, _tokenId) <
                limits[uint8(TypeMint.HASH_CHIP_NFT)],
            "Times limit"
        );
        require(
            hashChipNFTContract.ownerOf(_tokenId) == _address,
            "Wrong owner"
        );
        hashChipNFTContract.setTimesOfRegeneration(
            season,
            _tokenId,
            hashChipNFTContract._numberOfRegenerations(season, _tokenId) + 1
        );

        emit RegenerationFromHashChip(
            _address,
            monsterContract.mintMonster(
                _address,
                uint8(TypeMint.HASH_CHIP_NFT),
                false
            ),
            seeds,
            _tokenId,
            address(hashChipNFTContract),
            _monsterIdGame
        );
    }

    /*
     * Create a Monster by type
     * @param _typeMint: address of owner
     * @param _addressContract: address of contract
     * @param _chainId: chain id
     * @param _account: account
     * @param _tokenId: token id
     * @param _usingCost: used fee cost
     * @param _cost: fee
     * @param _deadline: deadline sig
     * @param _sig: signature
     * @param _mainSeed: mainseed
     * @param _subSeed: subseed
     * @param _ticketIds: _ticketIds
     * @param _ticketAmounts: _ticketAmounts
     * @param _itemFusionIds: _itemFusionIds
     * @param _itemFusionAmounts: _itemFusionAmounts
     */
    function mintMonster(MintParams calldata _mintParams)
        external
        payable
        nonReentrant
    {
        require(_mintParams.deadline > block.timestamp, "Deadline exceeded");
        require(!_isSigned[_mintParams.sig], "Signature used");
        require(_mintParams.account == msg.sender, "Not owner");
        address signer = recoverOAS(
            uint8(_mintParams.typeMint),
            _mintParams.account,
            uint8(_mintParams.usingCost),
            _mintParams.cost,
            _mintParams.deadline,
            _mintParams.sig
        );
        require(signer == validator, "Validator fail signature");

        if (
            _mintParams.typeMint == TypeMint.NFT ||
            _mintParams.typeMint == TypeMint.COLLABORATION_NFT
        ) {
            require(
                _mintParams.tokenIds.length == 1,
                "Valid tokenIds"
            );
            _fromExternalNFT(
                msg.sender,
                _mintParams.typeMint,
                _mintParams.chainId,
                _mintParams.addressContract,
                _mintParams.tokenIds[0],
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.FREE) {
            require(
                _mintParams.tokenIds.length == 0,
                "Valid tokenIds"
            );
            _mintMonsterFree(
                msg.sender,
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.GENESIS_HASH) {
            require(
                _mintParams.tokenIds.length == 1,
                "Valid tokenIds"
            );
            _fromGenesisHash(
                msg.sender,
                _mintParams.tokenIds[0],
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.GENERAL_HASH) {
            require(
                _mintParams.tokenIds.length == 1,
                "Valid tokenIds"
            );
            _fromGeneralHash(
                msg.sender,
                _mintParams.tokenIds[0],
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.HASH_CHIP_NFT) {
            require(
                _mintParams.tokenIds.length == 1,
                "Valid tokenIds"
            );
            _fromHashChipNFT(
                msg.sender,
                _mintParams.tokenIds[0],
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.REGENERATION_ITEM) {
            require(
                _mintParams.tokenIds.length == 1,
                "Valid tokenIds"
            );
            _mintMonsterFromRegeneration(
                msg.sender,
                uint8(_mintParams.tokenIds[0]),
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.FUSION_GENESIS_HASH) {
            require(
                _mintParams.itemFusionIds.length ==
                    _mintParams.itemFusionAmounts.length,
                "Input error"
            );
            require(
                _mintParams.tokenIds.length == 2,
                "Valid tokenIds"
            );
            if (_mintParams.itemFusionIds.length > 0) {
                fusionItem.burnMultipleItem(
                    msg.sender,
                    _mintParams.itemFusionIds,
                    _mintParams.itemFusionAmounts
                );
            }
            _fusionGenesisHash(
                msg.sender,
                _mintParams.tokenIds,
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.FUSION_GENERAL_HASH) {
            require(
                _mintParams.itemFusionIds.length ==
                    _mintParams.itemFusionAmounts.length,
                "Input error"
            );
            require(
                _mintParams.tokenIds.length == 2,
                "Valid tokenIds"
            );
            if (_mintParams.itemFusionIds.length > 0) {
                fusionItem.burnMultipleItem(
                    msg.sender,
                    _mintParams.itemFusionIds,
                    _mintParams.itemFusionAmounts
                );
            }
            _fusionGeneralHash(
                msg.sender,
                _mintParams.tokenIds,
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.FUSION_MULTIPLE_HASH) {
            require(
                _mintParams.itemFusionIds.length ==
                    _mintParams.itemFusionAmounts.length,
                "Input error"
            );
            require(
                _mintParams.tokenIds.length == 2,
                "Valid tokenIds"
            );
            if (_mintParams.itemFusionIds.length > 0) {
                fusionItem.burnMultipleItem(
                    msg.sender,
                    _mintParams.itemFusionIds,
                    _mintParams.itemFusionAmounts
                );
            }
            _fusionMultipleHash(
                msg.sender,
                _mintParams.tokenIds,
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else if (_mintParams.typeMint == TypeMint.FUSION_MONSTER) {
            require(
                _mintParams.itemFusionIds.length ==
                    _mintParams.itemFusionAmounts.length,
                "Input error"
            );
            require(
                _mintParams.tokenIds.length == 2,
                "Valid tokenIds"
            );
            if (_mintParams.itemFusionIds.length > 0) {
                fusionItem.burnMultipleItem(
                    msg.sender,
                    _mintParams.itemFusionIds,
                    _mintParams.itemFusionAmounts
                );
            }
            _fusionMonsterNFT(
                msg.sender,
                _mintParams.tokenIds,
                _mintParams.seed,
                _mintParams.monsterIdGame
            );
        } else {
            revert("Unsupported type");
        }

        if (_mintParams.usingCost == CostMint.OAS) {
            require(
                payable(receiveFee).send(_mintParams.cost),
                "Failed to claim OAS"
            );
        } else if (_mintParams.usingCost == CostMint.XXX) {
            tokenBaseContract.burnToken(msg.sender, _mintParams.cost);
        } else if (_mintParams.usingCost == CostMint.TICKET) {
            require(
                _mintParams.ticketIds.length > _mintParams.ticketAmounts.length,
                "Valid ticket"
            );
            require(
                _mintParams.ticketIds.length > 0,
                "Valid ticketIds > 0"
            );
            for (
                uint8 index = 0;
                index < _mintParams.ticketIds.length;
                index++
            ) {
                require(
                    usingTicket[uint8(_mintParams.ticketIds[index])],
                    "Item is not supported"
                );
                regenerationItem.burn(
                    msg.sender,
                    _mintParams.ticketIds[index],
                    _mintParams.ticketAmounts[index]
                );
            }
        }
    }

    /*
     * Create a Monster by regeneration items
     */
    function _mintMonsterFromRegeneration(
        address account,
        uint8 _itemId,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        require(regenerationItem.isMintMonster(_itemId), "Wrong id");
        regenerationItem.burn(account, _itemId, 1);
        emit RegenerationFromItems(
            account,
            monsterContract.mintMonster(
                account,
                uint8(TypeMint.REGENERATION_ITEM),
                false
            ),
            _seeds,
            _itemId,
            address(regenerationItem),
            _monsterIdGame
        );
    }

    /*
     * Create a Monster free
     */
    function _mintMonsterFree(
        address owner,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        emit RegenerationFreeMonster(
            owner,
            monsterContract.mintMonster(owner, uint8(TypeMint.FREE), true),
            _seeds,
            _monsterIdGame
        );
    }

    /*
     * fusion a Monster
     * @param _address: address of owner
     * @param _tokenIds: tokenIds fusion
     * @param _mainSeed: mainseed
     * @param _subSeed: subseed
     */
    function _fusionMonsterNFT(
        address _owner,
        uint256[] memory _tokenIds,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            monsterContract.ownerOf(_tokenIds[0]) == _owner,
            "The owner is not correct"
        );
        require(
            monsterContract.ownerOf(_tokenIds[1]) == _owner,
            "The owner is not correct"
        );
        bool lifeSpanFistMonster = monsterContract.getStatusMonster(
            _tokenIds[0]
        );
        bool lifeSpanLastMonster = monsterContract.getStatusMonster(
            _tokenIds[1]
        );
        if (!lifeSpanFistMonster) {
            monsterMemory.mint(_owner, _tokenIds[0]);
        }
        if (!lifeSpanLastMonster) {
            monsterMemory.mint(_owner, _tokenIds[1]);
        }
        bool isFee;
        if (
            monsterContract.isFreeMonster(_tokenIds[0]) ||
            monsterContract.isFreeMonster(_tokenIds[1])
        ) {
            isFee = true;
        }
        monsterContract.burn(_tokenIds[0]);
        monsterContract.burn(_tokenIds[1]);
        emit FusionMonsterNFT(
            _owner,
            monsterContract.mintMonster(
                _owner,
                uint8(TypeMint.FUSION_MONSTER),
                isFee
            ),
            _tokenIds,
            _seeds,
            address(monsterContract),
            _monsterIdGame
        );
    }

    /*
     * Create monster from fusion genersis hash
     * @param _owner: address of owner
     * @param _tokenIds: tokenIds fusion
     * @param _mainSeed: mainseed
     * @param _subSeed: subseed
     */
    function _fusionGenesisHash(
        address _owner,
        uint256[] memory _tokenIds,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            IERC721(address(genesisHashContract)).ownerOf(_tokenIds[0]) ==
                _owner,
            "The owner is not correct"
        );
        require(
            IERC721(address(genesisHashContract)).ownerOf(_tokenIds[1]) ==
                _owner,
            "The owner is not correct"
        );
        require(
            genesisHashContract._numberOfRegenerations(season, _tokenIds[0]) <
                limits[uint8(TypeMint.GENESIS_HASH)] &&
                genesisHashContract._numberOfRegenerations(
                    season,
                    _tokenIds[1]
                ) <
                limits[uint8(TypeMint.GENESIS_HASH)],
            "Exceed the allowed number of times"
        );

        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[0],
            genesisHashContract._numberOfRegenerations(season, _tokenIds[0]) + 1
        );
        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[1],
            genesisHashContract._numberOfRegenerations(season, _tokenIds[1]) + 1
        );
        emit FusionGenesisHash(
            _owner,
            _tokenIds,
            monsterContract.mintMonster(
                _owner,
                uint8(TypeMint.FUSION_GENESIS_HASH),
                false
            ),
            _seeds,
            address(genesisHashContract),
            _monsterIdGame
        );
    }

    /*
     * Create monster from fusion general hash
     * @param _owner: address of owner
     * @param _tokenIds: tokenIds fusion
     * @param _mainSeed: mainseed
     * @param _subSeed: subseed
     */
    function _fusionGeneralHash(
        address _owner,
        uint256[] memory _tokenIds,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            generalHashContract.ownerOf(_tokenIds[0]) == _owner,
            "The owner is not correct"
        );
        require(
            generalHashContract.ownerOf(_tokenIds[1]) == _owner,
            "The owner is not correct"
        );
        require(
            generalHashContract._numberOfRegenerations(season, _tokenIds[0]) <
                limits[uint8(TypeMint.GENERAL_HASH)] &&
                generalHashContract._numberOfRegenerations(
                    season,
                    _tokenIds[1]
                ) <
                limits[uint8(TypeMint.GENERAL_HASH)],
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[0],
            generalHashContract._numberOfRegenerations(season, _tokenIds[0]) + 1
        );
        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[1],
            generalHashContract._numberOfRegenerations(season, _tokenIds[1]) + 1
        );

        if (
            generalHashContract._numberOfRegenerations(season, _tokenIds[0]) +
                1 ==
            limits[uint8(TypeMint.GENERAL_HASH)]
        ) {
            generalHashContract.burn(_tokenIds[0]);
        }
        if (
            generalHashContract._numberOfRegenerations(season, _tokenIds[1]) +
                1 ==
            limits[uint8(TypeMint.GENERAL_HASH)]
        ) {
            generalHashContract.burn(_tokenIds[1]);
        }
        emit FusionGeneralHash(
            _owner,
            _tokenIds,
            monsterContract.mintMonster(
                _owner,
                uint8(TypeMint.FUSION_GENERAL_HASH),
                false
            ),
            _seeds,
            address(generalHashContract),
            _monsterIdGame
        );
    }

    /*
     * Create monster from fusion genesis + general hash
     * @param _owner: address of owner
     * @param _tokenIds: tokenIds fusion
     * @param _mainSeed: mainseed
     * @param _subSeed: subseed
     */
    function _fusionMultipleHash(
        address _owner,
        uint256[] memory _tokenIds,
        uint8[] memory _seeds,
        uint8 _monsterIdGame
    ) private {
        require(
            genesisHashContract.ownerOf(_tokenIds[0]) == _owner,
            "The owner is not correct"
        );
        require(
            generalHashContract.ownerOf(_tokenIds[1]) == _owner,
            "The owner is not correct"
        );
        require(
            genesisHashContract._numberOfRegenerations(season, _tokenIds[0]) <
                limits[uint8(TypeMint.GENESIS_HASH)] &&
                generalHashContract._numberOfRegenerations(
                    season,
                    _tokenIds[1]
                ) <
                limits[uint8(TypeMint.GENERAL_HASH)],
            "Exceed the allowed number of times"
        );
        genesisHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[0],
            genesisHashContract._numberOfRegenerations(season, _tokenIds[0]) + 1
        );
        generalHashContract.setTimesOfRegeneration(
            season,
            _tokenIds[1],
            generalHashContract._numberOfRegenerations(season, _tokenIds[1]) + 1
        );
        if (
            generalHashContract._numberOfRegenerations(season, _tokenIds[1]) +
                1 ==
            limits[uint8(TypeMint.GENERAL_HASH)]
        ) {
            generalHashContract.burn(_tokenIds[1]);
        }
        emit FusionMultipleHash(
            _owner,
            _tokenIds,
            monsterContract.mintMonster(
                _owner,
                uint8(TypeMint.FUSION_MULTIPLE_HASH),
                false
            ),
            _seeds,
            address(genesisHashContract),
            address(generalHashContract),
            _monsterIdGame
        );
    }

    function _refreshTimesOfRegeneration(
        TypeMint _typeMint,
        uint256 _chainId,
        address _address,
        uint256 _tokenId,
        CostMint _usingCost,
        uint256 _cost
    ) private {
        if (_usingCost == CostMint.OAS) {
            bool sent = payable(receiveFee).send(_cost);
            require(sent, "TreasuryContract::reward: Failed to claim OAS");
        } else {
            tokenBaseContract.burnToken(msg.sender, _cost);
        }
        if (_typeMint == TypeMint.NFT) {
            require(
                _timesRegenExternal[season][_chainId][_address][_tokenId] ==
                    limits[uint8(TypeMint.NFT)],
                "Item being used"
            );
            _timesRegenExternal[season][_chainId][_address][_tokenId] = 0;
        } else if (_typeMint == TypeMint.COLLABORATION_NFT) {
            require(
                _timesRegenExternal[season][_chainId][_address][_tokenId] ==
                    limits[uint8(TypeMint.COLLABORATION_NFT)],
                "Item being used"
            );
            _timesRegenExternal[season][_chainId][_address][_tokenId] = 0;
        } else if (_typeMint == TypeMint.GENESIS_HASH) {
            require(
                genesisHashContract._numberOfRegenerations(season, _tokenId) ==
                    limits[uint8(TypeMint.GENESIS_HASH)],
                "Item being used"
            );
            genesisHashContract.setTimesOfRegeneration(season, _tokenId, 0);
        } else if (_typeMint == TypeMint.HASH_CHIP_NFT) {
            require(
                hashChipNFTContract._numberOfRegenerations(season, _tokenId) ==
                    limits[uint8(TypeMint.HASH_CHIP_NFT)],
                "Item being used"
            );
            hashChipNFTContract.setTimesOfRegeneration(season, _tokenId, 0);
        } else {
            revert("Unsupported type");
        }
    }

    /*
     * get Fee mint Monster by TyMint & tokenId
     * @param _typeMint: TypeMint
     * @param _chainId: chainId
     * @param _address: address
     * @param _tokenId: tokenId
     */
    function getFeeOfTokenId(
        TypeMint _typeMint,
        uint256 _chainId,
        address _address,
        uint256 _tokenId
    ) public view returns (uint256 fee) {
        if (_typeMint == TypeMint.NFT) {
            fee = costOfNfts[
                _timesRegenExternal[season][_chainId][_address][_tokenId]
            ];
        } else if (_typeMint == TypeMint.COLLABORATION_NFT) {
            fee = costOfExternal[
                _timesRegenExternal[season][_chainId][_address][_tokenId]
            ];
        } else if (_typeMint == TypeMint.GENESIS_HASH) {
            fee = costOfGenesis[
                genesisHashContract._numberOfRegenerations(season, _tokenId)
            ];
        } else if (_typeMint == TypeMint.GENERAL_HASH) {
            fee = costOfGeneral[
                generalHashContract._numberOfRegenerations(season, _tokenId)
            ];
        } else if (_typeMint == TypeMint.HASH_CHIP_NFT) {
            fee = costOfHashChip[
                hashChipNFTContract._numberOfRegenerations(season, _tokenId)
            ];
        } else {
            revert("Unsupported type");
        }
    }

    /*
     * Refresh Times Of Regeneration
     * @param _type: address of owner
     * @param _chainId: chainId
     * @param _addressContract: addressContract
     * @param _account: account
     * @param _tokenId: first tokenId fusion
     * @param _usingCost: last tokenId fusion
     * @param _cost: list fusion item, if dont using fusion item => _itemId = [0]
     * @param _deadline: number of fusion item
     * @param _sig: signature
     */
    function refreshTimesOfRegeneration(
        TypeMint _typeMint,
        uint256 _chainId,
        address _addressContract,
        address _account,
        uint256 _tokenId,
        CostMint _usingCost,
        uint256 _cost,
        uint256 _deadline,
        bytes calldata _sig
    ) external payable nonReentrant {
        require(_deadline > block.timestamp, "Deadline exceeded");
        require(!_isSigned[_sig], "Signature used");
        address signer = recoverOAS(
            uint8(_typeMint),
            _account,
            uint8(_usingCost),
            _cost,
            _deadline,
            _sig
        );
        require(signer == validator, "Validator fail signature");
        _refreshTimesOfRegeneration(
            _typeMint,
            _chainId,
            _addressContract,
            _tokenId,
            _usingCost,
            _cost
        );
    }

    function isERC721(address contractAddress) internal view returns (bool) {
        try
            IERC721(contractAddress).supportsInterface(
                type(IERC721).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    function isERC1155(address contractAddress) internal view returns (bool) {
        try
            IERC1155(contractAddress).supportsInterface(
                type(IERC1155).interfaceId
            )
        returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }

    /*
     * encode data
     * @param _typeMint: type mint Monster
     * @param usingCost: Using cost mint NFT
     * @param cost: fee mint NFT
     * @param deadline: deadline using signature
     */
    function encodeOAS(
        uint8 _typeMint,
        address account,
        uint8 usingCost,
        uint256 cost,
        uint256 deadline
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(_typeMint, account, usingCost, cost, deadline)
            );
    }

    /*
     * recover data
     * @param _typeMint: type mint Monster
     * @param usingCost: Using cost mint NFT
     * @param cost: fee mint NFT
     * @param deadline: deadline using signature
     * @param signature: signature encode data
     */
    function recoverOAS(
        uint8 _typeMint,
        address _account,
        uint8 usingCost,
        uint256 cost,
        uint256 deadline,
        bytes calldata signature
    ) public pure returns (address) {
        return
            ECDSA.recover(
                ECDSA.toEthSignedMessageHash(
                    encodeOAS(
                        _typeMint,
                        _account,
                        uint8(usingCost),
                        cost,
                        deadline
                    )
                ),
                signature
            );
    }
}
