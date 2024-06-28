require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");


/** @type import('hardhat/config').HardhatUserConfig */

const { BASE_RPC_URL, PRIVATE_KEY, ETHERSCAN_APIKEY } = process.env || ""

module.exports = {
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
            gasPrice: 3000000000,
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