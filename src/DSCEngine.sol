//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    DecentralisedStableCoin private i_dsc;

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

    function mintDsc(uint256 amountDscToMint) external {}

    function burnDsc() external {}

    function liquidateDsc() external {}

    function getHealthFactor() external view {}
}
