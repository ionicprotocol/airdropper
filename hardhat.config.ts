import { vars, type HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-verify";

const config: HardhatUserConfig = {
  solidity: "0.8.23",
  networks: {
    hardhat: {
      forking: {
        url: "https://mainnet.mode.network",
      },
    },
    mode: {
      url: "https://mainnet.mode.network",
      accounts: [vars.get("DEPLOYER_PK")],
    },
  },
  etherscan: {
    apiKey: "",
    customChains: [
      {
        chainId: 34443,
        network: "mode",
        urls: {
          apiURL: "https://explorer.mode.network/api?",
          browserURL: "https://explorer.mode.network/",
        },
      },
    ],
  },
  sourcify: {
    enabled: true,
  },
};

export default config;
