// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Import necessary contracts from Uniswap
import './Interfaces/IUniswapV2Pair.sol';
import './Lib/UniswapV2Library.sol';
import './Lib/TransferHelper.sol';
import 'solady/src/utils/ReentrancyGuard.sol';
import {IWETH} from "./Interfaces/IWETH.sol";

contract AssetScooper is ReentrancyGuard {
 address private immutable i_owner;

 string private constant i_version = '1.0.0';

 address private constant WETH = 0x4200000000000000000000000000000000000006;

 address private constant factory = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;

 event TokenSwapped(
  address indexed user,
  address indexed tokenA,
  uint256 amountIn,
  uint amountOut
 );
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'EXPIRED');
        _;
    }


 error AssetScooper__AddressZero();
 error AssetScooper__MisMatchToken();
 error AssetScooper__ZeroLengthArray();
 error AssetScooper__UnsupportedToken();
 error AssetScooper__InsufficientOutputAmount();
 error AssetScooper__InsufficientLiquidity();
 error AssetScooper__UnsuccessfulBalanceCall();
 error AssetScooper__UnsuccessfulDecimalCall();
 error AssetScooper_PairDoesNotExist();
 error AssetScooper__InsufficientBalance();
 error AssetScooper__MisMatchLength();
 error AssetScooper__UnsuccessfulSwapTx();

 constructor() {
  i_owner = msg.sender;
 }

 function owner() public view returns (address) {
  return i_owner;
 }

 function version() public pure returns (string memory) {
  return i_version;
 }

 function _getAmountIn(
  address token,
  uint256 tokenBalance
 ) internal view returns (uint256 amountIn) {
  (bool success, bytes memory data) = token.staticcall(
   abi.encodeWithSignature('decimals()')
  );
  if (!success) revert AssetScooper__UnsuccessfulDecimalCall();
  uint256 tokenDecimals = abi.decode(data, (uint256));
  amountIn = (tokenBalance * (10 ** (18 - tokenDecimals))) / 1;
 }

 function _getTokenBalance(
  address token,
  address _owner
 ) internal view returns (uint256 tokenBalance) {
  (bool success, bytes memory data) = token.staticcall(
   abi.encodeWithSignature('balanceOf(address)', _owner)
  );
  if (!success) revert AssetScooper__UnsuccessfulBalanceCall();
  tokenBalance = abi.decode(data, (uint256));
 }
 
    function sweepTokens(
        address[] calldata tokenAddress,
        uint256[] calldata minAmountOut
    ) public nonReentrant {
        if (tokenAddress.length == 0) revert AssetScooper__ZeroLengthArray();
        if (tokenAddress.length != minAmountOut.length) revert AssetScooper__MisMatchLength();

        address[] memory path = new address[](2);
        path[1] = WETH;

        uint totalETH;

        for (uint256 i = 0; i < tokenAddress.length; i++) {
            path[0] = tokenAddress[i];
            uint amountIn = _getTokenBalance(tokenAddress[i], msg.sender);
            totalETH += swap(amountIn, minAmountOut[i], path, block.timestamp + 1000);
        }
        TransferHelper.safeTransfer(WETH, msg.sender, totalETH);
    }

     function swap(uint amountIn, uint amountOutMin, address[] memory path, uint deadline) private ensure(deadline) returns (uint amount) {
        require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        uint[] memory amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        return amounts[amounts.length - 1];
    }


    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

}
