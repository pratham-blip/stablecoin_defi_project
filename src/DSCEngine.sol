//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 *
 *@title DSCEngine
 *@author Pratham
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine {
    error DSC__EngineMoreThanZero();
    error DSC__TokenAddressesAndPriceFeedsLengthMismatch();

    mapping(address token => address priceFeed) private s_priceFeeds;

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) revert DSC__EngineMoreThanZero();
        _;
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSC__TokenAddressesAndPriceFeedsLengthMismatch();
        }

        for (int i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
    }

    function depositCollateralandMintDsc() external {}

    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    ) external moreThanZero(amountCollateral) {}

    function redeemDscAndWithdrawCollateral() external {}

    function redeemCollateral() external {}

    function burnDsc() external {}

    function liquidateDsc() external {}

    function getHealthFactor() external view {}
}
