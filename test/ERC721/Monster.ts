import { ethers } from 'ethers';

enum TypeMint {
  EXTERNAL_NFT,
  GENESIS_HASH,
  GENERAL_HASH,
  HASH_CHIP_NFT,
  REGENERATION_ITEM,
  FREE,
  FUSION,
}

function encodeOAS(
  _type: TypeMint,
  cost: number,
  tokenId: number,
  chainId: number,
  deadline: number
): string {
  const encoded = ethers.utils.defaultAbiCoder.encode(
    ['uint8', 'uint256', 'uint256', 'uint256', 'uint256'],
    [_type, cost, tokenId, chainId, deadline]
  );
  return ethers.utils.keccak256(encoded);
}

function recoverOAS(
  _type: TypeMint,
  cost: number,
  tokenId: number,
  chainId: number,
  deadline: number,
  sig: string
): string {
  const hash = encodeOAS(_type, cost, tokenId, chainId, deadline);
  const signingMessage = ethers.utils.arrayify(hash);
  const recoveredAddress = ethers.utils.recoverAddress(signingMessage, sig);
  return recoveredAddress;
}

const signature = '0x...'; // Replace with the actual signature
const recoveredAddress = recoverOAS(TypeMint.EXTERNAL_NFT, 10, 123, 1, 1631673600, signature);

console.log(recoveredAddress);
