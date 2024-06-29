const { getNamedAccounts, deployments, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config.cjs");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let args = [];

    if (network.name && (chainId == 31337)) {
        log("Local network detected, deploying mocks!")

        await deploy("MOCKERC20", {
            from: deployer,
            // gasLimit: 5000000,
            log: true,
            args: args,
            waitConfirmations: network.config.blockConfirmations
        });
        log("Mocks deployed!")
        log(".....................................")
    }
}

module.exports.tags = ["all", "mocks"]