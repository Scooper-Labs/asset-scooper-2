require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()
require('hardhat-deploy')

/** @type import('hardhat/config').HardhatUserConfig */

const { BASE_RPC_URL, PRIVATE_KEY, ETHERSCAN_APIKEY } = process.env || ''

module.exports = {
<<<<<<< HEAD:hardhat.config.cjs
    solidity: {
        compilers: [
            { version: "0.5.16" },
            { version: "0.8.12" },
            { version: "0.8.20" },
            { version: "0.8.4" },
            { version: "0.6.6" },
            { version: "0.6.0" }
        ]
    },
    defaultNetwork: "hardhat",
    networks: {
        base: {
            url: BASE_RPC_URL || "",
            gas: 2100000,
            gasPrice: 8000000000,
            gasLimit: 4000000,
            accounts: [PRIVATE_KEY],
            chainId: 8453,
            blockConfirmations: 6,
            ignition: {
                maxFeePerGasLimit: 50_000_000_000n,
                maxPriorityFeePerGas: 2_000_000_000n,
            },
        }
    },
=======
 solidity: {
  compilers: [
   { version: '0.8.1' },
   { version: '0.8.12' },
   { version: '0.8.19' },
   { version: '0.8.20' },
  ],
 },
 defaultNetwork: 'base',
 networks: {
  base: {
   url: 'https://mainnet.base.org',
   accounts: [PRIVATE_KEY],
   verify: {
>>>>>>> 6b9cdc9fc705a502819047aa37ef16430fb6ef94:hardhat.config.js
    etherscan: {
     apiUrl: 'https://api.basescan.org/api',
     apiKey: ETHERSCAN_APIKEY,
    },
   },
  },
  klaytn: {
   url: BASE_RPC_URL || '',
   gasPrice: 1000000000,
   accounts: [PRIVATE_KEY],
   chainId: 8453,
   blockConfirmations: 6,
  },
 },
 etherscan: {
  apikey: ETHERSCAN_APIKEY,
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
