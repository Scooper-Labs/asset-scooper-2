const { getNamedAccounts, deployments, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    if (developmentChains.includes(network.name)) {
        log("Local network detected, deploying mocks!")

        await deploy("MOCKERC20", {
            from: deployer,
            log: true,
            args: args,
            waitConfirmations: network.config.blockConfirmations
        })
        log("Mocks deployed!")
        log(".....................................")
    }
}

module.exports.tags = ["all", "mocks"]