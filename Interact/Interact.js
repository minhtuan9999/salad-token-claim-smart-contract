import Web3 from "web3";

//========CONFIG ENV================================================================================
CHAIN_NETWORK = 20197; // Testnet
// CHAIN_NETWORK = 29548; // Mainnet

RPC = "https://rpc.sandverse.oasys.games"; // Testnet
// RPC = "https://rpc.oasys.mycryptoheroes.net" // Mainnet

PATH_METAMASK = "";
ADDRESS_MARKETPLACE = "";
ADDRESS_MONSTER = "";
ADDRESS_FARM = "";
ADDRESS_GENESIS = "";
ADDRESS_GENERAL = "";
ADDRESS_SHOP = "";

//========CREATE ABI CONTRACT===========================================================================
const ABI_MARKETPLACE = [];
const ABI_MONSTER = [];
const ABI_FARM = [];
const ABI_GENESIS = [];
const ABI_GENERAL = [];
const ABI_SHOP = [];

//========CREATE PROVINDE===============================================================================
if (window.ethereum && ethereum.networkVersion == CHAIN_NETWORK) {
  console.log("Provider metamask");
  var provider = new Web3(window.ethereum);
} else {
  console.log("Provider RPC");
  var provider = new Web3(new Web3.providers.HttpProvider(RPC));
}

//==================DEEPLINK INSTALL METAMASK==============================================================
async function installMetamask() {
  window.open("https://metamask.app.link/dapp/" + PATH_METAMASK, "_blank");
}

//==================CHANGE NETWORK METAMASK==================================================================
const changeNetworkInMetamask = async (chainId) => {
  var params;
  switch (chainId) {
    case 29548:
      params = [
        {
          chainId: "0x736C",
          chainName: "MCH Verse",
          nativeCurrency: {
            symbol: "OAS",
            decimals: 18,
          },
          rpcUrls: ["https://rpc.oasys.mycryptoheroes.net/"],
          blockExplorerUrls: ["https://explorer.oasys.mycryptoheroes.net/"],
        },
      ];
      break;
    case 20197:
      params = [
        {
          chainId: "0x4EE5",
          chainName: "Sand Verse - Testnet",
          nativeCurrency: {
            symbol: "OAS",
            decimals: 18,
          },
          rpcUrls: ["https://rpc.sandverse.oasys.games/"],
          blockExplorerUrls: ["https://explorer.sandverse.oasys.games/"],
        },
      ];
      break;
  }
  // Check if MetaMask is installed
  // MetaMask injects the global API into window.ethereum
  if (window.ethereum) {
    try {
      switch (chainId) {
        case 29548:
          // check if the chain to connect to is installed
          await window.ethereum.request({
            method: "wallet_switchEthereumChain",
            params: [{ chainId: "0x736C" }], // chainId must be in hexadecimal numbers
          });
          break;
        case 20197:
          // check if the chain to connect to is installed
          await window.ethereum.request({
            method: "wallet_switchEthereumChain",
            params: [{ chainId: "0x4EE5" }], // chainId must be in hexadecimal numbers
          });
          break;
      }
    } catch (switchError) {
      // This error code indicates that the chain has not been added to MetaMask
      // if it is not, then install it into the user MetaMask
      if (switchError.code === 4902 || switchError.code === -32603) {
        try {
          await window.ethereum.request({
            method: "wallet_addEthereumChain",
            params: params,
          });
        } catch (addError) {
          console.error(addError);
        }
      }
      // console.error(error);
    }
  } else {
    // if no window.ethereum then MetaMask is not installed
    installMetamask();
    return;
  }
};

//==================CREATE CONTRACT===========================================================================
// Prepare the MARKETPLACE contract obj
var marketplaceContract = new provider.eth.Contract(
  ABI_MARKETPLACE,
  ADDRESS_MARKETPLACE
);
// Prepare the Monster contract obj
var monsterContract = new provider.eth.Contract(ABI_MONSTER, ADDRESS_MONSTER);
// Prepare the Farm contract obj
var farmContract = new provider.eth.Contract(ABI_FARM, ADDRESS_FARM);
// Prepare the Genesis hash contract obj
var genesisContract = new provider.eth.Contract(ABI_GENESIS, ADDRESS_GENESIS);
// Prepare the General hash contract obj
var generalContract = new provider.eth.Contract(ABI_GENERAL, ADDRESS_GENERAL);
// Prepare the SHOP contract obj
var shopContract = new provider.eth.Contract(ABI_SHOP, ABI_SHOP);

//==================MARKETPLACE===========================================================================
// Get list sale
const getListSale = async () => {
  try {
    return await marketplaceContract.methods.getListSale().call();
  } catch (error) {
    console.log(error);
    return [];
  }
};

// Get info sale by address
const getInfoSaleByAddress = async (address) => {
  try {
    return await marketplaceContract.methods
      .getInfoSaleByAddress(address)
      .call();
  } catch (error) {
    console.log(error);
    return [];
  }
};

// Set fee seller
const setFeeSeller = async (fee) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _setFeeSeller(fee);
  } catch (error) {
    console.log(error);
  }
};

const _setFeeSeller = async (fee) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.setFeeSeller(fee).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Set address fee
const setNewAddressFee = async (address) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _setNewAddressFee(address);
  } catch (error) {
    console.log(error);
  }
};

const _setNewAddressFee = async (address) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.setNewAddressFee(address).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Create market sell
/* Type NFT
- Farm: 0
- Monster: 1
- Genesis Hash: 2
- General Hash: 3
*/
const createMarketItemSale = async (typeNFT, tokenId, priceInWei, amount) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;
    let nftContract;
    let nftAddress;
    switch (typeNFT) {
      case 0:
        nftContract = farmContract;
        nftAddress = ADDRESS_FARM;
        break;
      case 1:
        nftContract = monsterContract;
        nftAddress = ADDRESS_MONSTER;
        break;
      case 2:
        nftContract = genesisContract;
        nftAddress = ADDRESS_GENESIS;
        break;
      case 3:
        nftContract = generalContract;
        nftAddress = ADDRESS_GENERAL;
        break;
      default:
        nftContract = monsterContract;
        nftAddress = ADDRESS_MONSTER;
        break;
    }

    if (
      (await nftContract.methods.getApproved(tokenId).call()) ==
      ADDRESS_MARKETPLACE
    ) {
      _createMarketItemSale(contracAddress, tokenId, priceInWei, amount);
    } else {
      const transactionParametersApprove = {
        from: ethereum.selectedAddress,
        to: nftAddress,
        data: nftContract.methods
          .approve(ADDRESS_MARKETPLACE, tokenId)
          .encodeABI(),
        chainId: CHAIN_NETWORK,
      };
      let txidApprove = await sendTransaction(transactionParametersApprove);
      console.log("txidApprove: ", txidApprove);
      await checkTransaction(txidApprove).then((status) => {
        if (status == true) {
          _createMarketItemSale(nftAddress, tokenId, priceInWei, amount);
        } else if (status == false) {
          console.log("Fail Transaction");
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
};

const _createMarketItemSale = async (
  contracAddress,
  tokenId,
  priceInWei,
  amount
) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods
        .createMarketItemSale(contracAddress, tokenId, priceInWei, amount)
        .encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Cancel market sale
const cancelMarketItemSale = async (orderId) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _cancelMarketItemSale(orderId);
  } catch (error) {
    console.log(error);
  }
};

const _cancelMarketItemSale = async (orderId) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods
        .cancelMarketItemSale(orderId)
        .encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Buy item
const buyItem = async (orderId, priceInWei) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;
    _buyItem(orderId, priceInWei);
  } catch (error) {
    console.log(error);
  }
};

const _buyItem = async (orderId, priceInWei) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.buyItem(orderId).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//========================SHOP===========================================================================
// Set address treasury
const setTreasuryAddress = async (address) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _setTreasuryAddress(address);
  } catch (error) {
    console.log(error);
  }
};

const _setTreasuryAddress = async (address) => {
  try {
    const transactionParameters = {
      to: ADDRESS_SHOP,
      data: shopContract.methods.setTreasuryAddress(address).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Buy item shop
/* Type 
- GENERAL_BOX: 0
- GENESIS_BOX: 1
- FARM_NFT: 2
- BIT: 3
*/
/* Group
- GROUP_A: 0
- GROUP_B: 1 
- GROUP_C: 2
- GROUP_D: 3
- GROUP_E: 4
*/
const buyItemShop = async (type, account, group, priceInWei, number, deadline, sig) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _buyItemShop(type, account, group, priceInWei, number, deadline, sig);
  } catch (error) {
    console.log(error);
  }
};

const _buyItemShop = async (type, account, group, priceInWei, number, deadline, sig) => {
  try {
    const transactionParameters = {
      to: ABI_SHOP,
      data: shopContract.methods.buyItem(type, account, group, price, number, deadline, sig).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Get list sale on shop
const getListSaleShop = async () => {
  try {
    return await shopContract.methods
      .getListSale()
      .call();
  } catch (error) {
    console.log(error);
    return [];
  }
};

//==================GENESIS=================================================================================
// Open box genesis
/* Group
- GROUP_A: 0
- GROUP_B: 1 
- GROUP_C: 2
- GROUP_D: 3
- GROUP_E: 4
*/
const openGenesisBox = async (group) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _openGenesisBox(group);
  } catch (error) {
    console.log(error);
  }
};

const _openGenesisBox = async (group) => {
  try {
    const transactionParameters = {
      to: ABI_GENESIS,
      data: genesisContract.methods.openGenesisBox(group).encodeABI(),
      chainId: CHAIN_NETWORK
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================GENERAL===================================================================================
// Open box general
/* Group
- GROUP_A: 0
- GROUP_B: 1 
- GROUP_C: 2
- GROUP_D: 3
- GROUP_E: 4
*/
const openGeneralBox = async (group) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _openGeneralBox(group);
  } catch (error) {
    console.log(error);
  }
};

const _openGeneralBox = async (group) => {
  try {
    const transactionParameters = {
      to: ABI_GENERAL,
      data: generalContract.methods.openGeneralBox(group).encodeABI(),
      chainId: CHAIN_NETWORK
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================FARM============================================================================================
// Training monster
const trainingMonster = async (farmId, monsterId) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    if (
      (await monsterContract.methods.getApproved(monsterId).call()) ==
      ADDRESS_FARM
    ) {
      _trainingMonster(farmId, monsterId);
    } else {
      const transactionParametersApprove = {
        from: ethereum.selectedAddress,
        to: ADDRESS_MONSTER,
        data: monsterContract.methods
          .approve(ADDRESS_FARM, monsterId)
          .encodeABI(),
        chainId: CHAIN_NETWORK,
      };
      let txidApprove = await sendTransaction(transactionParametersApprove);
      console.log("txidApprove: ", txidApprove);
      await checkTransaction(txidApprove).then((status) => {
        if (status == true) {
          _trainingMonster(farmId, monsterId);
        } else if (status == false) {
          console.log("Fail Transaction");
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
};

const _trainingMonster = async (farmId, monsterId) => {
  const transactionParameters = {
    to: ADDRESS_FARM,
    data: monsterContract.methods
      .trainingMonster(ADDRESS_MONSTER, farmId, monsterId)
      .encodeABI(),
    chainId: CHAIN_NETWORK,
  };

  return sendTransaction(transactionParameters);
};

// End training monster
const endTrainingMonster = async (farmId, monsterId) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _endTrainingMonster(farmId, monsterId);
  } catch (error) {
    console.log(error);
  }
};

const _endTrainingMonster = async (farmId, monsterId) => {
  const transactionParameters = {
    to: ADDRESS_FARM,
    data: monsterContract.methods
      .endTrainingMonster(ADDRESS_MONSTER, farmId, monsterId)
      .encodeABI(),
    chainId: CHAIN_NETWORK,
  };

  return sendTransaction(transactionParameters);
};

//==================MONSTER======================================================================================
// Mint monster from EXTERNAL_NFT, GENESIS_HASH, GENERAL_HASH, HASH_CHIP_NFT
/* Type
  - EXTERNAL_NFT: 0
  - GENESIS_HASH: 1
  - GENERAL_HASH: 2
  - HASH_CHIP_NFT: 3
*/ 
/* IsOAS
  - OAS: true
  - XXX: false
*/ 
const mintMonster = async (type,address, tokenId, isOas, priceInWei, deadline, sig) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _mintMonster(type,address, tokenId, isOas, priceInWei, deadline, sig);
  } catch (error) {
    console.log(error);
  }
};

const _mintMonster = async (type,address, tokenId, isOas, priceInWei, deadline, sig) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.mintMonster(type,address, tokenId, isOas, priceInWei, deadline, sig).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: isOas ? priceInWei : 0
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Mint monster free
const mintMonsterFree = async () => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _mintMonsterFree();
  } catch (error) {
    console.log(error);
  }
};

const _mintMonsterFree = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.mintMonsterFree().encodeABI(),
      chainId: CHAIN_NETWORK
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Mint monster from regeneration item
const mintMonsterFromRegeneration = async (itemId) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _mintMonsterFromRegeneration(itemId);
  } catch (error) {
    console.log(error);
  }
};

const _mintMonsterFromRegeneration = async (itemId) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.mintMonsterFromRegeneration(itemId).encodeABI(),
      chainId: CHAIN_NETWORK
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Fusion monster
const fusionMonsterNFT = async (address, firstToken, lastToken) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _fusionMonsterNFT(address, firstToken, lastToken);
  } catch (error) {
    console.log(error);
  }
};

const _fusionMonsterNFT = async (address, firstToken, lastToken) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionMonsterNFT(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Fusion by genesis
const fusionGenesisHash = async (address, firstToken, lastToken) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _fusionGenesisHash(address, firstToken, lastToken);
  } catch (error) {
    console.log(error);
  }
};

const _fusionGenesisHash = async (address, firstToken, lastToken) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionGenesisHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};
// Fusion by general
const fusionGeneralHash = async (address, firstToken, lastToken) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _fusionGeneralHash(address, firstToken, lastToken);
  } catch (error) {
    console.log(error);
  }
};

const _fusionGeneralHash = async (address, firstToken, lastToken) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionGeneralHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Fusion by genesis x general
const fusionMultipleHash = async (address, firstToken, lastToken) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _fusionMultipleHash(address, firstToken, lastToken);
  } catch (error) {
    console.log(error);
  }
};

const _fusionMultipleHash = async (address, firstToken, lastToken) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionMultipleHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Reset time of regeneration
const refreshTimesOfRegeneration = async (type, address, tokenId, isOAS, priceInWei, deadline, sig) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _refreshTimesOfRegeneration(type, address, tokenId, isOAS, priceInWei, deadline, sig);
  } catch (error) {
    console.log(error);
  }
};

const _refreshTimesOfRegeneration = async (type, address, tokenId, isOAS, priceInWei, deadline, sig) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.refreshTimesOfRegeneration(type, address, tokenId, isOAS, priceInWei, deadline, sig).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: isOAS ? priceInWei : 0
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================SEND TRANSACTION============================================================================
const sendTransaction = async (transactionParameters) => {
  console.log("transactionParameters ", transactionParameters);
  transactionParameters["from"] = ethereum.selectedAddress;
  const txHash = await ethereum
    .request({
      method: "eth_sendTransaction",
      params: [transactionParameters],
    })
    .then((res) => {
      if (res) {
        console.log("Txid: ", res);
        return res;
      } else {
        console.log("Reject transaction");
      }
    })
    .catch((error) => {
      console.log(error);
    });
  return txHash;
};

// Check success transaction
const checkTransaction = async (txid) => {
  let checkSuccess = setInterval(async function () {
    var receipt = await provider.eth.getTransactionReceipt(txid);
    if (receipt?.status) {
      clearInterval(checkSuccess);
      console.log("Success: ", txid);
      return true;
    } else if (receipt?.status == false) {
      clearInterval(checkSuccess);
      console.log("fail txid", txid);
      return false;
    }
  }, 2000);
};
