import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 29548;
ADDRESS_MARKETPLACE = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_MARKETPLACE = [];

//========CREATE PROVINDE===============================================================
if (window.ethereum && ethereum.networkVersion == CHAIN_NETWORK) {
  console.log("Provider metamask");
  var provider = new Web3(window.ethereum);
} else {
  console.log("Provider RPC");
  var provider = new Web3(
    new Web3.providers.HttpProvider("https://rpc.oasys.mycryptoheroes.net")
  );
}

//==================CREATE CONTRACT===========================================
// Prepare the FARM contract obj
var marketplaceContract = new provider.eth.Contract(ABI_MARKETPLACE, ADDRESS_MARKETPLACE);

//==================MARKETPLACE===========================================
// Get list sale
const getListSale = async () => {
  try {
    return (await marketplaceContract.methods.getListSale().call())
  } catch (error) {
    console.log(error);
    return [];
  }
};

// Get info sale by address
const getInfoSaleByAddress = async (address) => {
  try {
    return (await marketplaceContract.methods.getInfoSaleByAddress(address).call())
  } catch (error) {
    console.log(error);
    return [];
  }
};

// Set Decimals fee
const _setDecimalsFee = async (decimal) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.setDecimalsFee(decimal).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Set free seller
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
const _setNewAddressFee= async (address) => {
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

// Create market item sale
const _createMarketItemSale = async (contracAddress, tokenId, priceInWei, amount) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.createMarketItemSale(contracAddress, tokenId, priceInWei, amount).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Create cancel market item sale
const _cancelMarketItemSale = async (orderId) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.cancelMarketItemSale(orderId).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

// Buy NFT
const _buyItem = async (orderId) => {
  try {
    const transactionParameters = {
      to: ADDRESS_MARKETPLACE,
      data: marketplaceContract.methods.buyItem(orderId).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================SEND TRANSACTION==========================================
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
