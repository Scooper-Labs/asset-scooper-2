const { ethers } = require("hardhat");
const { BASE_RPC_URL } = process.env || "";

const checkDeployment = async (contractAddress) => {

    const provider = new ethers.JsonRpcProvider(BASE_RPC_URL);
    const code = await provider.getCode(contractAddress);
    if (code === "0x") {
        console.log(`No contract deployed at: ${contractAddress}`);
    } else {
        console.log(`Contract deployed at: ${contractAddress}`);
    }

}

module.exports = {
    checkDeployment
}
