//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 *
 *@title DecentralisedStableCoin
 *@author Pratham
 *Collateral : Exogenous (ETH & BTC)
 *Minting : Algorithmic
 *Relative Stability :  pegged
 *this is the contract of simple erc20 implementation of StableCoin This contract is to be governed by DSCEngine.
 */

contract DecentralisedStableCoin is ERC20Burnable, Ownable {
    error DecentralisedStableCoin_amount_should_be_greater_than_zero();
    error DecentralisedStableCoin_insufficient_balance_for_burning();
    error DecentralisedStableCoin_NotZeroAddress();

    constructor()
        ERC20("DecentralisedStableCoin", "DSC")
        Ownable(0x103092D2A29bA4769ccA13F70D172e16D5e3bcCF)
    {}

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);

        if (_amount <= 0) {
            revert DecentralisedStableCoin_amount_should_be_greater_than_zero();
        }

        if (balance < _amount) {
            revert DecentralisedStableCoin_insufficient_balance_for_burning();
        }

        super.burn(_amount);
    }

    function mint(
        address _to,
        uint256 _amount
    ) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralisedStableCoin_NotZeroAddress();
        }

        if (_amount <= 0) {
            revert DecentralisedStableCoin_amount_should_be_greater_than_zero();
        }

        _mint(_to, _amount);
        return true;
    }
}
