// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Import necessary contracts from Uniswap
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import './Lib/TransferHelper.sol';
import 'solady/src/utils/ReentrancyGuard.sol';
  
contract AssetScooper is ReentrancyGuard {

    address private immutable i_owner;

    address private immutable WETH;

    IUniswapV2Router02 private immutable i_uniswapV2Router;

    IUniswapV2Factory private immutable i_uniswapV2Factory;

    string private constant i_version = "1.0.0";

    uint public constant MINIMUM_LIQUIDITY = 10**3;

    bytes4 private constant interfaceId = 0x01ffc9a7;

    event TokenSwapped(address indexed token, uint amountIn, uint amountOut);
    
    error AssetScooper__AddressZero();
    error AssetScooper__WethToken();
    error AssetScooper__ZeroLengthArray();
    error AssetScooper__UnsupportedToken();
    error AssetScooper__InsufficientOutputAmount();
    error AssetScooper__InsufficientLiquidity();
    error AssetScooper__UnsuccessfulBalanceCall();
    error AssetScooper__UnsuccessfulDecimalCall();
    error AssetScooper_PairDoesNotExist();
    error AssetScooper__InsufficientBalance();

    constructor(address _router) {
        i_owner = msg.sender;
        i_uniswapV2Router = IUniswapV2Router02(_router);
        i_uniswapV2Factory = IUniswapV2Factory(i_uniswapV2Router.factory());
        WETH = i_uniswapV2Router.WETH();
    }

    function owner() public view returns (address) {
        return i_owner;
    }

    function version() public pure returns (string memory) {
        return i_version;
    }

    function router() public view returns (address) {
        return address(i_uniswapV2Router);
    }

    function _checkIfERC20Token(address tokenAddress) internal view returns (bool) {
        (bool success, bytes memory data) = tokenAddress.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)", interfaceId));
        if(!success) revert AssetScooper__UnsupportedToken();
        return abi.decode(data, (bool));
    }

    function _checkIfPairExists(address tokenAddress) internal view returns (bool) {
        (bool success, bytes memory data) = address(i_uniswapV2Factory).staticcall(abi.encodeWithSignature("getPair(address,address)", tokenAddress, WETH));
        if(!success) revert AssetScooper_PairDoesNotExist();
        address pairAddress = abi.decode(data, (address));
        return pairAddress != address(0);
    }

    function _getTokenAmount(address token, uint256 tokenBalance) internal view returns (uint256 tokenAmount) {
        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSignature("decimals()"));
        if(!success) revert AssetScooper__UnsuccessfulDecimalCall();
        uint256 tokenDecimals = abi.decode(data, (uint256));
        tokenAmount = (tokenBalance * (10 ** (18 - tokenDecimals))) / 1;
    }

    function _getTokenBalance(address token, address _owner) internal view returns (uint256) {
        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSignature("balanceOf(address)", _owner));
        if(!success) revert AssetScooper__UnsuccessfulBalanceCall();
        return abi.decode(data, (uint256));
    }

    function sweepTokens(address[] calldata tokenAddress, uint256 minAmountOut) public {
        if(tokenAddress.length == 0) revert AssetScooper__ZeroLengthArray();
        if(msg.sender == address(0)) revert AssetScooper__AddressZero();

        address token; 

        for (uint256 i = 0; i < tokenAddress.length; i++) {
            token = tokenAddress[i];
        }

        _swap(token, minAmountOut);
    }

    function _swap(address tokenAddr, uint256 minAmountOut) internal nonReentrant {

        if(tokenAddr == address(0)) revert AssetScooper__AddressZero();
        if(tokenAddr == WETH) revert AssetScooper__WethToken();

        if(!_checkIfERC20Token(tokenAddr)) revert AssetScooper__UnsupportedToken();
        if(!_checkIfPairExists(tokenAddr)) revert AssetScooper_PairDoesNotExist();

        uint256 tokenBalance = _getTokenBalance(tokenAddr, msg.sender);

        if (tokenBalance < 0) revert AssetScooper__InsufficientBalance();

        uint256 tokenAmount = _getTokenAmount(tokenAddr, tokenBalance);

        TransferHelper.safeTransferFrom(tokenAddr, msg.sender, address(this), tokenBalance);
        TransferHelper.safeApprove(tokenAddr, address(i_uniswapV2Router), tokenBalance);

        address[] memory path = new address[](2);
        path[0] = tokenAddr;
        path[1] = WETH;
        uint[] memory amountsOut = i_uniswapV2Router.getAmountsOut(tokenBalance, path);

        if(amountsOut[1] <= MINIMUM_LIQUIDITY) revert AssetScooper__InsufficientLiquidity();

        uint[] memory amounts = IUniswapV2Router02(i_uniswapV2Router).swapExactTokensForETH(
            tokenAmount,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        if(amounts[1] < minAmountOut) revert AssetScooper__InsufficientOutputAmount();

        emit TokenSwapped(tokenAddr, tokenBalance, amounts[1]);

    }

}