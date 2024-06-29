const { getNamedAccounts, deployments, network } = require("hardhat");
const { verify } = require('../utils/verify.cjs');
const { checkDeployment } = require("../utils/checkDeployment.cjs");
const { developmentChains } = require("../helper-hardhat-config.cjs");
const { ETHERSCAN_APIKEY } = process.env || "";

const deployAssetScooper = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const { chainId } = network.config.chainId;
    // const UNISWAP_V2_ROUTER = "0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24";
    let args = [];

    const assetScooper = await deploy("AssetScooper", {
        from: deployer,
        args: args,
        log: true,
        blockConfirmations: network.config.blockConfirmations
    });

    log("Deploying..................................................");
    log("...........................................................");
    log(assetScooper.address);
    await checkDeployment(assetScooper.address);

    if (!(chainId == 31337) && (chainId == 8453) && ETHERSCAN_APIKEY) {
        await verify(assetScooper.address, args);
    }
}

module.exports.tags = ["all", "assetScooper"];
module.exports.default = deployAssetScooper;

