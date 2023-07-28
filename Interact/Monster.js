import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 20197;
ADDRESS_CONTRACT = "";
PATH_METAMASK = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_CONTRACT = [];

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
// Prepare the contract obj
var contract = new provider.eth.Contract(ABI_CONTRACT, ADDRESS_CONTRACT);

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

//==================SET STATUS MONSTER===========================================
const setStatusMonster = async (tokenId, status) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);
    if (networkId != CHAIN_NETWORK) return;
    _setStatusMonster(tokenId, status);
  } catch (error) {
    console.log(error);
  }
};

const _setStatusMonster = async (tokenId, status) => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.setStatusMonster(tokenId, status).encodeABI(),
      chainId: CHAIN_NETWORK
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================MINT MONSTER===========================================
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
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================MINT MONSTER FREE===========================================
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
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================MINT MONSTER BY REGENERATION===========================================
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

const _mintMonsterFromRegeneration = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.mintMonsterFromRegeneration(itemId).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================FUSION MONSTER===========================================
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

const _fusionMonsterNFT = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionMonsterNFT(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================FUSION BY GENESIS===========================================
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

const _fusionGenesisHash = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionGenesisHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};
//==================FUSION BY GENERAL===========================================
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

const _fusionGeneralHash = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionGeneralHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================FUSION BY GENERAL X GENESIS===========================================
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

const _fusionMultipleHash = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.fusionMultipleHash(address, firstToken, lastToken).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};

//==================FUSION BY GENERAL X GENESIS===========================================
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

const _refreshTimesOfRegeneration = async () => {
  try {
    const transactionParameters = {
      to: ABI_CONTRACT,
      data: contract.methods.refreshTimesOfRegeneration(type, address, tokenId, isOAS, priceInWei, deadline, sig).encodeABI(),
      chainId: CHAIN_NETWORK,
      value: priceInWei
    };

    return sendTransaction(transactionParameters);
  } catch (error) {
    console.log(error);
  }
};