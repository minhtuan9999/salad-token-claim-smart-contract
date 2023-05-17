// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Test721 is ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;
    EnumerableSet.UintSet private  listNFT;
    constructor() ERC721("MyNFT", "MNFT") {
        for (uint256 i = 0; i < 100; i++) 
        {
            _mint(msg.sender, i);
            listNFT.add(i);
        }
    }

    function getList() view public returns (uint256 [] memory) {
        return listNFT.values();
    }


}