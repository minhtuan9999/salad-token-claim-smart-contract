import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 29548;
ADDRESS_SHOP = "";
ADDRESS_TOKEN = "";
PATH_METAMASK = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_SHOP = [];
const ABI_TOKEN = [];

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
// Prepare the SHOP contract obj
var shopContract = new provider.eth.Contract(ABI_SHOP, ABI_SHOP);
// Prepare the OAS contract obj
var tokenContract = new provider.eth.Contract(ABI_TOKEN, ADDRESS_TOKEN);

//==================SHOP===========================================
// Get list asset
const getListAsset = async () => {
  try {
    return (await shopContract.methods.getListAsset().call())
  } catch (error) {
    console.log(error);
    return [];
  }
};

// Get info asset
const getInfoAsset = async (contracAddress, typeNFT) => {
  try {
    return (await shopContract.methods.getInfoAsset(contracAddress, typeNFT).call())
  } catch (error) {
    console.log(error);
    return [];
  }
};

//==================SET ADDRESS===========================================
const setNewAddress = async (address) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    _setNewAddress(address);
  } catch (error) {
    console.log(error);
  }
};

const _setNewAddress = async (address) => {
  try {
    const transactionParameters = {
      to: ADDRESS_SHOP,
      data: shopContract.methods.setNewAddress(address).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================CREATE ASSET===========================================
const createAsset = async (contracAddress, typeNFT, priceInWei, startTime, endTime) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;
    _createAsset(contracAddress, typeNFT, priceInWei, startTime, endTime)
  } catch (error) {
    console.log(error);
  }
};

const _createAsset = async (contracAddress, typeNFT, priceInWei, startTime, endTime) => {
  try {
    const transactionParameters = {
      to: ADDRESS_SHOP,
      data: shopContract.methods.createAsset(contracAddress, typeNFT, priceInWei, startTime, endTime).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};


//==================REMOVE ASSET===========================================
const removeAsset = async (contracAddress, typeNFT) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;
    _removeAsset(contracAddress, typeNFT)
  } catch (error) {
    console.log(error);
  }
};

const _removeAsset = async (contracAddress, typeNFT) => {
  try {
    const transactionParameters = {
      to: ADDRESS_SHOP,
      data: shopContract.methods.removeAsset(contracAddress, typeNFT).encodeABI(),
      chainId: CHAIN_NETWORK,
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================BUY ITEM===========================================
const buyItem = async (contractAddress, typeNFT, amount) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    let assetInfo = await shopContract.methods.getInfoAsset(contractAddress, typeNFT).call();

    if (
      (await tokenContract.methods.allowance(ethereum.selectedAddress, ADDRESS_SHOP).call()) >= (assetInfo.priceInWei * amount)
    ) {
      _buyItem(contractAddress, typeNFT, amount);
    } else {
      const transactionParametersApprove = {
        from: ethereum.selectedAddress,
        to: ABI_TOKEN,
        data: tokenContract.methods
          .approve(ADDRESS_SHOP, assetInfo.priceInWei * amount)
          .encodeABI(),
        chainId: CHAIN_NETWORK,
      };
      let txidApprove = await sendTransaction(transactionParametersApprove);
      console.log("txidApprove: ", txidApprove);
      await checkTransaction(txidApprove).then((status) => {
        if (status == true) {
          _buyItem(contractAddress, typeNFT, amount);
        } else if (status == false) {
          console.log("Fail Transaction");
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
};

const _buyItem = async (contractAddress, typeNFT, amount) => {
  try {
    const transactionParameters = {
      to: ABI_SHOP,
      data: shopContract.methods.buyItem(contractAddress, typeNFT, amount).encodeABI(),
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
