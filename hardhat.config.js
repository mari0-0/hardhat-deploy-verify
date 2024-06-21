require("@nomicfoundation/hardhat-toolbox")
require("@nomicfoundation/hardhat-verify")
require("dotenv").config()
require("./tasks/block-number")
require("solidity-coverage")

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY1
const ETHERSCAN_APIKEY = process.env.ETHERSCAN_APIKEY
const OPSCAN_APIKEY = process.env.OPSCAN_APIKEY
const CMC_APIKEY = process.env.CMC_APIKEY
const BASE_SEPOLIA_RPC_URL = process.env.BASE_SEPOLIA_RPC_URL
const OP_SEPOLIA_RPC_URL = process.env.OP_SEPOLIA_RPC_URL
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    defaultNetwork: "hardhat",
    solidity: "0.8.24",
    networks: {
        sepolia: {
            url: SEPOLIA_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 11155111,
        },
        baseSepolia: {
            url: BASE_SEPOLIA_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 84532,
        },
        opSepolia: {
            url: OP_SEPOLIA_RPC_URL,
            accounts: [PRIVATE_KEY],
            chainId: 11155420,
        },
        localhost: {
            url: "http://127.0.0.1:8545",
            chainId: 31337,
        },
    },
    etherscan: {
        apiKey: {
            mainnet: ETHERSCAN_APIKEY,
            opSepolia: OPSCAN_APIKEY,
        },
        customChains: [
            {
              network: "opSepolia",
              chainId: 11155420,
              urls: {
                apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
                browserURL: "https://sepolia-optimistic.etherscan.io/"
              }
            }
          ]
    },
    sourcify: {
        // Disabled by default
        // Doesn't need an API key
        enabled: true,
    },
    gasReporter: {
        enabled: false,
        outputFile: "gas-report.txt",
        noColors: true,
        currency: "USD",
        coinmarketcap: CMC_APIKEY,
        // token: "MATIC",
    },
}
