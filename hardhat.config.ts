import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config()

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    mchVerseTestnet: {
      url: "https://rpc.sandverse.oasys.games/",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      allowUnlimitedContractSize: true,
    },
    mchVerseMainnet: {
      url: "https://rpc.oasys.mycryptoheroes.net/",
      accounts: process.env.PRIVATE_KEY!== undefined? [process.env.PRIVATE_KEY] : [],
      allowUnlimitedContractSize: true,
    }
  },
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

export default config;
