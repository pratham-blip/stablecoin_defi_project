//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
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

contract DSCEngine is ReentrancyGuard {
    error DSC__EngineMoreThanZero();
    error DSC__TokenAddressesAndPriceFeedsLengthMismatch();
    error DSC__EngineNotAllowedToken();
    error DSC__EngineTransferFailed();

    mapping(address token => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount))
        private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DscMinted;

    address[] private s_collateralTokens;

    DecentralisedStableCoin private immutable i_dsc;

    event Collateraldeposited(
        address indexed user,
        address indexed token,
        uint256 amount
    );

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) revert DSC__EngineMoreThanZero();
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0))
            revert DSC__EngineNotAllowedToken();
    }

    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSC__TokenAddressesAndPriceFeedsLengthMismatch();
        }

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }
    }

    function depositCollateralandMintDsc() external {}

    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][
            tokenCollateralAddress
        ] += amountCollateral;

        emit Collateraldeposited(
            msg.sender,
            tokenCollateralAddress,
            amountCollateral
        );

        bool success = IERC20(tokenCollateralAddress).transferFrom(
            msg.sender,
            address(this),
            amountCollateral
        );
        if (!success) {
            revert DSC__EngineTransferFailed();
        }
    }

    function redeemDscAndWithdrawCollateral() external {}

    function redeemCollateral() external {}

    function mintDsc(
        uint256 amountDscToMint
    ) external moreThanZero(amountDscToMint) nonReentrant {
        s_DscMinted[msg.sender] += amountDscToMint;

        //if they minted too much
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function liquidateDsc() external {}

    function getHealthFactor() external view {}

    //private & internal view  functions//

    function _getAccountInfo(
        address user
    )
        private
        view
        returns (uint256 totalDscMinted, uint256 totalCollateralValueInUsd)
    {
        //total dsc minted
        //total collateral value deposited
        totalDscMinted = s_DscMinted[user];
        totalCollateralValueInUsd = getCollateralValue(user);
    }

    /** Returns how close a user to a liquadation is
       if he is below 1,  they gonna get liquidated
     */
    function _healthFactor(address user) private view returns (uint256) {
        //total dsc minted
        //total collateral value deposited
        (
            uint256 totalDscMinted,
            uint256 totalCollateralValueInUsd
        ) = _getAccountInfo(user);
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        /*1. we are gonna check the health factor (do they have enough collateral?)
        2. if they don't have enough collateral, we are gonna revert */
    }

    //public and external functions ////

    function getCollateralValue(address user) public view returns (uint256) {
        //map through each collateral token , get amount  they have deposited , and map it to
        //the price , and get the usd value

        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
        }
    }

    function getUsdValue(
        address token,
        uint256 amount
    ) public view returns (uint256) {}
}
