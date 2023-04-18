import Web3 from "web3";

//========CONFIG ENV====================================================================
CHAIN_NETWORK = 29548;
ADDRESS_FARM = "";

//========CREATE ABI CONTRACT===========================================================
const ABI_FARM = [];

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
var farmContract = new provider.eth.Contract(ABI_FARM, ADDRESS_FARM);

//==================FARM===========================================
const check = async () => {
  try {
    const transactionParameters = {
      to: ADDRESS_FARM,
      data: farmContract.methods.check().encodeABI(),
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
