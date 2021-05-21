pragma solidity =0.5.16;

import '../AllERC20.sol';

contract ERC20 is AllERC20 {
    constructor(uint _totalSupply) public {
        _mint(msg.sender, _totalSupply);
    }
}
