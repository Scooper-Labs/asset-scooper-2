require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");


/** @type import('hardhat/config').HardhatUserConfig */

const { BASE_RPC_URL, PRIVATE_KEY, ETHERSCAN_APIKEY } = process.env || ""

module.exports = {
    solidity: {
        compilers: [
            { version: "0.8.1" },
            { version: "0.8.12" },
            { version: "0.8.19" },
            { version: "0.8.20" }
        ]
    },
    defaultNetwork: "hardhat",
    networks: {
        klaytn: {
            url: BASE_RPC_URL || "",
            gasPrice: 1000000000,
            accounts: [PRIVATE_KEY],
            chainId: 8453,
            blockConfirmations: 6
        }
    },
    etherscan: {
        apikey: ETHERSCAN_APIKEY,
    },
    sourcify: {
        enabled: true,
    },
    gasReporter: {
        enabled: true,
        outputFile: "gas-report.txt",
        noColors: true
    },
    namedAccounts: {
        deployer: {
            default: 0
        }
    }

};