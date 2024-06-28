const { network, ethers } = require("hardhat");
const { verify } = require('../utils/verify');
const { developmentChains } = require("../helper-hardhat-config");
const { ETHERSCAN_APIKEY } = process.env || "";

const deployAssetScooper = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;
    const UNISWAP_ROUTER_V2 = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

    const args = [UNISWAP_ROUTER_V2];

    const assetScooper = await deploy("AssetScooper", {
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: network.config.blockConfirmations
    });

    log("Deploying..................................................")
    log("...........................................................")
    log(assetScooper.address);

    // if (!developmentChains.includes(network.name) && chainId == 8453 && ETHERSCAN_APIKEY) {
    //     await verify(assetScooper.address, args);
    // }
}

module.exports.default = deployAssetScooper;
module.exports.tags = ["all", "assetScooper"];

