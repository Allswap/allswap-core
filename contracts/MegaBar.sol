// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// MegaBar is the coolest bar in town. You come in with some Mega, and leave with more! The longer you stay, the more Mega you get.
//
// This contract handles swapping to and from xMega, AllSwap's staking token.
contract MegaBar is ERC20("MegaBar", "xMEGA"){
    using SafeMath for uint256;
    IERC20 public mega;

    // Define the Mega token contract
    constructor(IERC20 _mega) public {
        mega = _mega;
    }

    // Enter the bar. Pay some MEGAs. Earn some shares.
    // Locks Mega and mints xMega
    function enter(uint256 _amount) public {
        // Gets the amount of Mega locked in the contract
        uint256 totalMega = mega.balanceOf(address(this));
        // Gets the amount of xMega in existence
        uint256 totalShares = totalSupply();
        // If no xMega exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalMega == 0) {
            _mint(msg.sender, _amount);
        }
        // Calculate and mint the amount of xMega the Mega is worth. The ratio will change overtime, as xMega is burned/minted and Mega deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalMega);
            _mint(msg.sender, what);
        }
        // Lock the Mega in the contract
        mega.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your MEGAs.
    // Unlocks the staked + gained Mega and burns xMega
    function leave(uint256 _share) public {
        // Gets the amount of xMega in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Mega the xMega is worth
        uint256 what = _share.mul(mega.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        mega.transfer(msg.sender, what);
    }
}
