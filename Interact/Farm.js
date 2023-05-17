import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 29548;
ADDRESS_FARM = "";
ADDRESS_MONSTER = "";
ADDRESS_TOKEN = "";
PATH_METAMASK = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_FARM = [];
const ABI_MONSTER = [];
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
// Prepare the FARM contract obj
var farmContract = new provider.eth.Contract(ABI_FARM, ADDRESS_FARM);
// Prepare the MONSTER contract obj
var monsterContract = new provider.eth.Contract(ABI_MONSTER, ADDRESS_MONSTER);
// Prepare the OAS contract obj
var tokenContract = new provider.eth.Contract(ABI_TOKEN, ADDRESS_TOKEN);

//==================GET BALANCE OAS===========================================
const getBalanceOAS = async (address) => {
  let balance = await tokenContract.methods.balanceOf(address).call();
  return balance;
};

//==================BUY FARM===========================================
const buyFarm = async (buyer, packageID) => {
  try {
    await changeNetworkInMetamask(CHAIN_NETWORK);
    let networkId = await window.ethereum.request({
      method: "eth_chainId",
    });
    networkId = await Web3.utils.hexToNumberString(networkId);

    if (networkId != CHAIN_NETWORK) return;

    let balance = await getBalanceOAS(buyer);
    let infoPackage = await farmContract.methods
      .getInforPackage(packageID)
      .call();
    let price = infoPackage.price;
    if (!infoPackage.isSale || balance < price) return;

    if (
      (await tokenContract.methods.allowance(buyer, ADDRESS_FARM).call()) >=
      price
    ) {
      _buyFarm(packageID);
    } else {
      const transactionParametersApprove = {
        from: buyer,
        to: ADDRESS_TOKEN,
        data: tokenContract.methods.approve(ADDRESS_FARM, price).encodeABI(),
        chainId: CHAIN_NETWORK,
      };

      let txidApprove = await sendTransaction(transactionParametersApprove);
      console.log("txidApprove: ", txidApprove);
      await checkTransaction(txidApprove).then((status) => {
        if (status == true) {
          _buyFarm(packageID);
        } else if (status == false) {
          console.log("Fail Transaction");
        }
      });
    }
  } catch (error) {
    console.log(error);
  }
};

const _buyFarm = async (packageID) => {
  const transactionParameters = {
    to: ADDRESS_FARM,
    data: farmContract.methods.buyFarm(packageID).encodeABI(),
    chainId: CHAIN_NETWORK,
  };

  return sendTransaction(transactionParameters);
};

//==================TRAINING MONSTER===========================================
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

//==================END TRAINING MONSTER===========================================
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
      console.log("fail txid", txidApprove);
      return false;
    }
  }, 2000);
};
