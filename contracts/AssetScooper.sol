// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Import necessary contracts from Uniswap
import './Interfaces/IUniswapV2Pair.sol';
import './Lib/UniswapV2Library.sol';
import './Lib/TransferHelper.sol';
import 'solady/src/utils/ReentrancyGuard.sol';

contract AssetScooper is ReentrancyGuard {
 address private immutable i_owner;

 string private constant i_version = '1.0.0';

 bytes4 private constant interfaceId = 0x01ffc9a7;

 address private constant weth = 0x4200000000000000000000000000000000000006;

 address private constant factory = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;

 event TokenSwapped(
  address indexed user,
  address indexed tokenA,
  uint256 amountIn,
  uint amountOut
 );

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

 function _checkIfERC20Token(
  address tokenAddress
 ) internal view returns (bool) {
  (bool success, bytes memory data) = tokenAddress.staticcall(
   abi.encodeWithSignature('supportsInterface(bytes4)', interfaceId)
  );
  if (!success) revert AssetScooper__UnsupportedToken();
  return abi.decode(data, (bool));
 }

 function _checkIfPairExists(
  address _factory,
  address tokenAddress
 ) internal pure returns (bool) {
  address pairAddress = UniswapV2Library.pairFor(_factory, tokenAddress, weth);
  return pairAddress != address(0);
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
  if (tokenAddress.length != minAmountOut.length)
   revert AssetScooper__MisMatchLength();

  uint256 totalEth;

  for (uint256 i = 0; i < tokenAddress.length; i++) {
   address pairAddress = UniswapV2Library.pairFor(
    factory,
    tokenAddress[i],
    weth
   );

   totalEth += _swap(pairAddress, minAmountOut[i]);
  }

<<<<<<< HEAD
            totalEth += _swap(pairAddress, minimumOutputAmount);
        }

        TransferHelper.safeTransferETH(msg.sender, totalEth);
    }

    function _swap(address pairAddress, uint256 minimumOutputAmount) internal nonReentrant returns(uint256 amountOut) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
=======
  TransferHelper.safeTransferETH(msg.sender, totalEth);
 }

 function _swap(
  address pairAddress,
  uint256 minimumOutputAmount
 ) internal nonReentrant returns (uint256 amountOut) {
  IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

  address tokenA = pair.token0();
  address tokenB = pair.token1();
>>>>>>> a4e4f9c02cc691c08aef9596bbcbb9b04dae481b

  if ((tokenA == address(0)) && (tokenB == address(0)))
   revert AssetScooper__AddressZero();
  if ((tokenA == weth) && (tokenB == tokenA))
   revert AssetScooper__MisMatchToken();

  if (!_checkIfERC20Token(tokenA)) revert AssetScooper__UnsupportedToken();
  if (!_checkIfPairExists(pair.factory(), tokenA))
   revert AssetScooper_PairDoesNotExist();

  uint256 tokenBalance = _getTokenBalance(tokenA, msg.sender);

  if (tokenBalance < 0) revert AssetScooper__InsufficientBalance();

  uint256 amountIn = _getAmountIn(tokenA, tokenBalance);

  (uint reserveA, uint reserveB) = UniswapV2Library.getReserves(
   pair.factory(),
   tokenA,
   tokenB
  );

  uint256 pairBalanceA = _getTokenBalance(tokenA, pairAddress);
  uint256 pairBalanceB = _getTokenBalance(tokenB, pairAddress);

<<<<<<< HEAD
        uint256 pairBalanceA = _getTokenBalance(tokenA, pairAddress);
        uint256 pairBalanceB = _getTokenBalance(tokenB, pairAddress);
=======
  if (pairBalanceB > pairBalanceA) {
   amountOut = UniswapV2Library.getAmountOut(amountIn, reserveA, reserveB);
  }
>>>>>>> a4e4f9c02cc691c08aef9596bbcbb9b04dae481b

  if (amountOut < minimumOutputAmount)
   revert AssetScooper__InsufficientOutputAmount();

  TransferHelper.safeTransferFrom(tokenA, msg.sender, pairAddress, amountIn);

<<<<<<< HEAD
        if (pairBalanceB > pairBalanceA) {
            pair.swap(0, amountOut, address(this), new bytes(0));
        }
=======
  if (pairBalanceB > pairBalanceA) {
   pair.swap(0, amountOut, address(this), new bytes(0));
  }
>>>>>>> a4e4f9c02cc691c08aef9596bbcbb9b04dae481b

  emit TokenSwapped(msg.sender, tokenA, amountIn, amountOut);
 }
}
