const { ethers, network, getNamedAccounts } = require("hardhat");
const deployer = getNamedAccounts().deployer;

const main = async () => {
    // const [signer1, signer2] = await ethers.getSigners();
    const ai_Inu = 0x8853F0c059C27527d33D02378E5E4F6d5afB574a;
    const usdc = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    const sofi = 0x703D57164CA270b0B330A87FD159CfEF1490c0a5;
    const dai = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

    const ai_Inu_Token = await ethers.getContractAt("IERC20", ai_Inu);
    const usdc_Token = await ethers.getContractAt("IERC20", usdc);
    const sofi_Token = await ethers.getContractAt("IERC20", sofi);
    const dai_Token = await ethers.getContractAt("IERC20", dai);

    const tokensArray = [ai_Inu_Token, usdc_Token, sofi_Token, dai_Token];
    const tokenAddresses = [ai_Inu, usdc, sofi, dai];

    const tokenHolder = 0x739120AdE7ED878FcA5bbDB806263a8258FE2360;
    const tokenSigner = await ethers.getImpersonatedSigner(tokenHolder);

    await network.provider.send("hardhat_setBalance", [
        tokenHolder,
        "0x8AFE18BB59AA6AB01280",
    ]);

    const to = deployer;
    // const contractAddress = 0x2Be3f47F734650423fc6Ba361860249A564C892b;
    const assetScooper = await ethers.getContractAt()
    // const assetScooper = await ethers.getContract("AssetScooper", deployer);

    const approvedValue = ethers.parseEther("5");

    for (i = 0; i < tokensArray.length; i++) {
        const token = tokensArray[i];
        const approve = await token
            .connect(tokenSigner)
            .approve(contractAddress, approvedValue);

        await approve.wait(6);
    }

    console.log(`Approved ${approvedValue} tokens for AssetScooper.`);

    const owner = assetScooper.owner();
    console.log(owner);
    const swap = await assetScooper.connect(tokenSigner).sweepTokens(tokenAddresses, 0);
    await swap.wait(6);

};

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});