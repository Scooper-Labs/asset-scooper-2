require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()
require('hardhat-deploy')

/** @type import('hardhat/config').HardhatUserConfig */

const { BASE_RPC_URL, PRIVATE_KEY, BASESCAN_APIKEY } = process.env || ''

if (!PRIVATE_KEY || !BASE_RPC_URL) {
  throw new Error("Please set your PRIVATE_KEY and BASE_RPC_URL in a .env file");
}


module.exports = {
    solidity: {
        compilers: [
            { version: "0.5.16" },
            { version: "0.8.12" },
            { version: "0.8.20" },
            { version: "0.8.4" },
            { version: "0.6.6" },
            { version: "0.6.0" },
            { version: "0.8.19" },
        ]
    },
    defaultNetwork: "base",
    networks: {
        base: {
            url: BASE_RPC_URL || "",
            accounts: [PRIVATE_KEY],
            chainId: 8453,
            blockConfirmations: 6,
            ignition: {
                maxFeePerGasLimit: 50_000_000_000,
                maxPriorityFeePerGas: 2_000_000_000,
            },
        }
    },
    etherscan: {
        apiKey: {
            base: BASESCAN_APIKEY || ""
        },
    },
    sourcify: {
        enabled: true,
    },
    gasReporter: {
        enabled: true,
        outputFile: 'gas-report.txt',
        noColors: true,
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
}