const { deployments, getNamedAccounts, ethers } = require("hardhat")
const { assert, expect } = require("chai");
const { developmentChains } = require("../../helper-hardhat-config.cjs");


!developmentChains.includes(network.name) ? describe.skip :
    describe("AssetScooper", async () => {

        let assetScooper;
        let mockERC20;
        let deployer;
        let tokenAddresses = [];
        const args = ["0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"];

        [owner, addr1, addr2] = await ethers.getSigners();

        beforeEach(async () => {
            deployer = (await getNamedAccounts()).deployer;
            await deployments.fixture(["all"]);
            assetScooper = await ethers.getContract("AssetScooper", deployer);
            mockERC20 = await ethers.getContract("MOCKERC20", deployer);
        });

        describe("Deployment", async () => {
            it("sets router address", async () => {
                const txresponse = await assetScooper.router();
                assert.equal(txresponse, args);
            });

            it("sets deployer's address", async () => {
                const tx = await assetScooper.owner();
                assert.equal(tx, deployer);
            });
        });

        describe("view functions", async () => {
            it("check version", async () => {
                const tx = await assetScooper.version();
                assert.equal(tx, "1.0.0");
            });

            it("check if pair exists", async () => {
                const tx = await assetScooper._checkIfPairExists(mockERC20.address);
                await expect(tx).to.be.revertedWith("AssetScooper__UnsuccessfulPairCheck")
            });

            it("check if erc20", async () => {
                const tx = await assetScooper._checkIfERC20Token(mockERC20.address);
                assert.equal(tx, true);
            });

            it("check owner", async () => {
                const tx = await assetScooper.owner();
                assert.equal(tx, deployer);
            });
        });

        describe("swap", async () => {
            it("reverts if token addresses doesn't exist", async () => {
                const swaptx = assetScooper.connect(addr1).sweepTokens(tokenAddresses, 0);
                await expect(swaptx).to.be.revertedWith("AssetScooper__ZeroLengthArray");
            });

            it("reverts if token is ERC20 compatible", async () => {
                const tx = assetScooper.connect(addr1).sweepTokens(deployer, 0);
                await expect(tx).to.be.revertedWith("AssetScooper__UnsupportedToken");
            });

            it("Should swap tokens for ETH", async function () {
                tokenAddresses[0] = mockERC20.address;
                const tokenAmount = ethers.utils.parseUnits("10", 18);

                await mockERC20.mint(addr1.address, tokenAmount);
                await mockERC20.connect(addr1).approve(assetScooper.address, tokenAmount);

                const tx = assetScooper.connect(addr1).sweepTokens(tokenAddresses, 0);
                await expect(tx)
                    .to.emit(tokensScooper, "TokensSwapped")
                    .withArgs(addr1.address, tokenAmount);

                const ethBalance = await assetScooper.WETH().balanceOf(addr1.address);
                assert.equal(ethBalance, tokenAmount);
            });
        });

    })