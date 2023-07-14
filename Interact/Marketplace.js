import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 29548;
ADDRESS_MARKETPLACE = "";
ADDRESS_NFT = "";
PATH_METAMASK = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_MARKETPLACE = [];
const ABI_NFT = [];

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

//==================DEEPLINK INSTALL METAMASK===========================================
async function installMetamask() {
  window.open("https://metamask.app.link/dapp/" + PATH_METAMASK, "_blank");
}

//==================CHANGE NETWORK METAMASK===========================================
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

//==================CREATE CONTRACT===========================================
// Prepare the MARKETPLACE contract obj
var marketplaceContract = new provider.eth.Contract(ABI_MARKETPLACE, ADDRESS_MARKETPLACE);
// Prepare the NFT contract obj
var nftContract = new provider.eth.Contract(ABI_NFT, ADDRESS_NFT);

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

//==================SET DECIMAL FEE===========================================
const setDecimalsFee = async (decimald) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _setDecimalsFee(decimal);
  } catch (error) {
    console.log(error);
  }
};

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

//==================SET FEE SELLER===========================================
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

//==================SET ADDRESS FEE===========================================
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

//==================CREATE MARKET SELL===========================================
const createMarketItemSale = async (contracAddress, tokenId, priceInWei, amount) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    if (
      (await nftContract.methods.getApproved(tokenId).call()) ==
      ADDRESS_MARKETPLACE
    ) {
      _createMarketItemSale(contracAddress, tokenId, priceInWei, amount);
    } else {
      const transactionParametersApprove = {
        from: ethereum.selectedAddress,
        to: ADDRESS_NFT,
        data: nftContract.methods
          .approve(ADDRESS_MARKETPLACE, tokenId)
          .encodeABI(),
        chainId: CHAIN_NETWORK,
      };
      let txidApprove = await sendTransaction(transactionParametersApprove);
      console.log("txidApprove: ", txidApprove);
      await checkTransaction(txidApprove).then((status) => {
        if (status == true) {
          _createMarketItemSale(contracAddress, tokenId, priceInWei, amount);
        } else if (status == false) {
          console.log("Fail Transaction");
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
};

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


//==================CANCEL MARKET SALE===========================================
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
      data: marketplaceContract.methods.cancelMarketItemSale(orderId).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================BUY ITEM===========================================
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
      value: priceInWei
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

//==================CHECK SUCCESS TRANSACTION==========================================
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