// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomBox {
    struct Check {
        uint256 a;
        uint256 b;
        uint256 c;
        uint256 d;
        uint256 e;
        uint256 t;
    }
    uint256 private nonce;
    constructor() {
        nonce = 0;
    }

    function totalM(
        uint256 tA,
        uint256 rA,
        uint256 tB,
        uint256 rB,
        uint256 tC,
        uint256 rC,
        uint256 tD,
        uint256 rD,
        uint256 tE,
        uint256 rE
    ) private pure returns (uint256) {
        return
            m(rA, tB, tC, tD, tE) +
            m(rB, tA, tC, tD, tE) +
            m(rC, tA, tB, tD, tE) +
            m(rD, tA, tB, tC, tE) +
            m(rE, tA, tB, tC, tD);
    }

    function m(
        uint256 r,
        uint256 t1,
        uint256 t2,
        uint256 t3,
        uint256 t4
    ) private pure returns (uint256) {
        return r * t1 * t2 * t3 * t4;
    }

    function total(
        uint256 tA,
        uint256 rA,
        uint256 tB,
        uint256 rB,
        uint256 tC,
        uint256 rC,
        uint256 tD,
        uint256 rD,
        uint256 tE,
        uint256 rE
    ) public pure returns (Check memory) {
        return
            Check(
                m(rA, tB, tC, tD, tE),
                m(rB, tA, tC, tD, tE),
                m(rC, tA, tB, tD, tE),
                m(rD, tA, tB, tC, tE),
                m(rE, tA, tB, tC, tD),
                totalM(tA, rA, tB, rB, tC, rC, tD, rD, tE, rE)
            );
    }

    function _generateRandomValue(
        uint256 tA,
        uint256 rA,
        uint256 tB,
        uint256 rB,
        uint256 tC,
        uint256 rC,
        uint256 tD,
        uint256 rD,
        uint256 tE,
        uint256 rE
    ) private returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, blockhash(block.number - 1), msg.sender, nonce)
            )
        );
        Check memory check = total(tA, rA, tB, rB, tC, rC, tD, rD, tE, rE);
        nonce++;
        return randomNumber % check.t;
    }


    function _determineTokenType(
        uint256 randomValue,
        uint256 tA,
        uint256 rA,
        uint256 tB,
        uint256 rB,
        uint256 tC,
        uint256 rC,
        uint256 tD,
        uint256 rD,
        uint256 tE,
        uint256 rE
    ) private pure returns (uint256) {
        Check memory check = total(tA, rA, tB, rB, tC, rC, tD, rD, tE, rE);
        if (randomValue < check.a) {
            return 1;
        } else if (randomValue < check.a + check.b) {
            return 2;
        } else if (randomValue < check.a + check.b + check.c) {
            return 3;
        } else if (randomValue < check.a + check.b + check.c + check.d) {
            return 4;
        } else {
            return 5;
        }
    }

    function openBox(
        uint256 tA,
        uint256 rA,
        uint256 tB,
        uint256 rB,
        uint256 tC,
        uint256 rC,
        uint256 tD,
        uint256 rD,
        uint256 tE,
        uint256 rE
    ) public returns (uint256) {
        if(rE == 0 && tE == 0) {
            tE = 1;
        }
        uint256 randomValue = _generateRandomValue(
            tA,
            rA,
            tB,
            rB,
            tC,
            rC,
            tD,
            rD,
            tE,
            rE
        );
        uint256 species = _determineTokenType(
            randomValue,
            tA,
            rA,
            tB,
            rB,
            tC,
            rC,
            tD,
            rD,
            tE,
            rE
        );
        return species;
    }
}