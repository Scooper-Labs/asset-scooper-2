// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MOCKERC20 is ERC20 {
    constructor() ERC20("Mock ERC20", "MKETH") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}