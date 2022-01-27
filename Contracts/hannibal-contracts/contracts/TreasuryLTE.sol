// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/Babylonian.sol";
import "./owner/Operator.sol";
import "./utils/ContractGuard.sol";
import "./interfaces/IBasisAsset.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IMasonry.sol";

/*
 ██░ ██  ▄▄▄       ███▄    █  ███▄    █  ██▓ ▄▄▄▄    ▄▄▄       ██▓         █████▒ ██▓ ███▄    █  ▄▄▄       ███▄    █  ▄████▄  ▓█████ 
▓██░ ██▒▒████▄     ██ ▀█   █  ██ ▀█   █ ▓██▒▓█████▄ ▒████▄    ▓██▒       ▓██   ▒ ▓██▒ ██ ▀█   █ ▒████▄     ██ ▀█   █ ▒██▀ ▀█  ▓█   ▀ 
▒██▀▀██░▒██  ▀█▄  ▓██  ▀█ ██▒▓██  ▀█ ██▒▒██▒▒██▒ ▄██▒██  ▀█▄  ▒██░       ▒████ ░ ▒██▒▓██  ▀█ ██▒▒██  ▀█▄  ▓██  ▀█ ██▒▒▓█    ▄ ▒███   
░▓█ ░██ ░██▄▄▄▄██ ▓██▒  ▐▌██▒▓██▒  ▐▌██▒░██░▒██░█▀  ░██▄▄▄▄██ ▒██░       ░▓█▒  ░ ░██░▓██▒  ▐▌██▒░██▄▄▄▄██ ▓██▒  ▐▌██▒▒▓▓▄ ▄██▒▒▓█  ▄ 
░▓█▒░██▓ ▓█   ▓██▒▒██░   ▓██░▒██░   ▓██░░██░░▓█  ▀█▓ ▓█   ▓██▒░██████▒   ░▒█░    ░██░▒██░   ▓██░ ▓█   ▓██▒▒██░   ▓██░▒ ▓███▀ ░░▒████▒
 ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░   ▒ ▒ ░ ▒░   ▒ ▒ ░▓  ░▒▓███▀▒ ▒▒   ▓▒█░░ ▒░▓  ░    ▒ ░    ░▓  ░ ▒░   ▒ ▒  ▒▒   ▓▒█░░ ▒░   ▒ ▒ ░ ░▒ ▒  ░░░ ▒░ ░
 ▒ ░▒░ ░  ▒   ▒▒ ░░ ░░   ░ ▒░░ ░░   ░ ▒░ ▒ ░▒░▒   ░   ▒   ▒▒ ░░ ░ ▒  ░    ░       ▒ ░░ ░░   ░ ▒░  ▒   ▒▒ ░░ ░░   ░ ▒░  ░  ▒    ░ ░  ░
 ░  ░░ ░  ░   ▒      ░   ░ ░    ░   ░ ░  ▒ ░ ░    ░   ░   ▒     ░ ░       ░ ░     ▒ ░   ░   ░ ░   ░   ▒      ░   ░ ░ ░           ░   
 ░  ░  ░      ░  ░         ░          ░  ░   ░            ░  ░    ░  ░            ░           ░       ░  ░         ░ ░ ░         ░  ░
                                                  ░                                                                  ░               
    http://han.finance
*/
contract Treasury is ContractGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /* ========= CONSTANT VARIABLES ======== */

    uint256 public constant PERIOD = 6 hours;

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;

    // flags
    bool public initialized = false;

    // epoch
    uint256 public startTime;
    uint256 public epoch = 0;
    uint256 public epochSupplyContractionLeft = 0;

    // exclusions from total supply
    address[] public excludedFromTotalSupply = [
        address(0x9A896d3c54D7e45B558BD5fFf26bF1E8C031F93b), // TombGenesisPool
        address(0xa7b9123f4b15fE0fF01F469ff5Eab2b41296dC0E), // new TombRewardPool
        address(0xA7B16703470055881e7EE093e9b0bF537f29CD4d) // old TombRewardPool
    ];

    // core components
    address public han;
    address public hbond;
    address public hashare;

    address public masonry;
    address public hanOracle;

    // price
    uint256 public hanPriceOne;
    uint256 public hanPriceCeiling;

    uint256 public seigniorageSaved;

    uint256[] public supplyTiers;
    uint256[] public maxExpansionTiers;

    uint256 public maxSupplyExpansionPercent;
    uint256 public bondDepletionFloorPercent;
    uint256 public seigniorageExpansionFloorPercent;
    uint256 public maxSupplyContractionPercent;
    uint256 public maxDebtRatioPercent;

    // 28 first epochs (1 week) with 4.5% expansion regardless of HANNIBAL price
    uint256 public bootstrapEpochs;
    uint256 public bootstrapSupplyExpansionPercent;

    /* =================== Added variables =================== */
    uint256 public previousEpochTombPrice;
    uint256 public maxDiscountRate; // when purchasing bond
    uint256 public maxPremiumRate; // when redeeming bond
    uint256 public discountPercent;
    uint256 public premiumThreshold;
    uint256 public premiumPercent;
    uint256 public mintingFactorForPayingDebt; // print extra HANNIBAL during debt phase

    address public daoFund;
    uint256 public daoFundSharedPercent;

    address public devFund;
    uint256 public devFundSharedPercent;

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);
    event BurnedBonds(address indexed from, uint256 bondAmount);
    event RedeemedBonds(address indexed from, uint256 hanAmount, uint256 bondAmount);
    event BoughtBonds(address indexed from, uint256 hanAmount, uint256 bondAmount);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event MasonryFunded(uint256 timestamp, uint256 seigniorage);
    event DaoFundFunded(uint256 timestamp, uint256 seigniorage);
    event DevFundFunded(uint256 timestamp, uint256 seigniorage);

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }

    modifier checkCondition {
        require(block.timestamp >= startTime, "Treasury: not started yet");

        _;
    }

    modifier checkEpoch {
        require(block.timestamp >= nextEpochPoint(), "Treasury: not opened yet");

        _;

        epoch = epoch.add(1);
        epochSupplyContractionLeft = (getTombPrice() > hanPriceCeiling) ? 0 : getTombCirculatingSupply().mul(maxSupplyContractionPercent).div(10000);
    }

    modifier checkOperator {
        require(
            IBasisAsset(han).operator() == address(this) &&
                IBasisAsset(hbond).operator() == address(this) &&
                IBasisAsset(hashare).operator() == address(this) &&
                Operator(masonry).operator() == address(this),
            "Treasury: need more permission"
        );

        _;
    }

    modifier notInitialized {
        require(!initialized, "Treasury: already initialized");

        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function nextEpochPoint() public view returns (uint256) {
        return startTime.add(epoch.mul(PERIOD));
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _han,
        address _hbond,
        address _hashare,
        address _hanOracle,
        address _masonry,
        uint256 _startTime
    ) public notInitialized {
        han = _han;
        hbond = _hbond;
        hashare = _hashare;
        hanOracle = _hanOracle;
        masonry = _masonry;
        startTime = _startTime;

        hanPriceOne = 10**18;
        hanPriceCeiling = hanPriceOne.mul(101).div(100);

        // Dynamic max expansion percent
        supplyTiers = [0 ether, 500000 ether, 1000000 ether, 1500000 ether, 2000000 ether, 5000000 ether, 10000000 ether, 20000000 ether, 50000000 ether];
        maxExpansionTiers = [450, 400, 350, 300, 250, 200, 150, 125, 100];

        maxSupplyExpansionPercent = 400; // Upto 4.0% supply for expansion

        bondDepletionFloorPercent = 10000; // 100% of Bond supply for depletion floor
        seigniorageExpansionFloorPercent = 3500; // At least 35% of expansion reserved for masonry
        maxSupplyContractionPercent = 300; // Upto 3.0% supply for contraction (to burn HANNIBAL and mint tBOND)
        maxDebtRatioPercent = 3500; // Upto 35% supply of tBOND to purchase

        premiumThreshold = 110;
        premiumPercent = 7000;

        // First 28 epochs with 4.5% expansion
        bootstrapEpochs = 28;
        bootstrapSupplyExpansionPercent = 450;

        // set seigniorageSaved to it's balance
        seigniorageSaved = IERC20(han).balanceOf(address(this));

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function _updateTombPrice() internal {
        try IOracle(hanOracle).update() {} catch {}
    }

    function getTombCirculatingSupply() public view returns (uint256) {
        IERC20 hanErc20 = IERC20(han);
        uint256 totalSupply = hanErc20.totalSupply();
        uint256 balanceExcluded = 0;
        for (uint8 entryId = 0; entryId < excludedFromTotalSupply.length; ++entryId) {
            balanceExcluded = balanceExcluded.add(hanErc20.balanceOf(excludedFromTotalSupply[entryId]));
        }
        return totalSupply.sub(balanceExcluded);
    }

    function buyBonds(uint256 _hanAmount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {
        require(_hanAmount > 0, "Treasury: cannot purchase bonds with zero amount");

        uint256 hanPrice = getTombPrice();
        require(hanPrice == targetPrice, "Treasury: HANNIBAL price moved");
        require(
            hanPrice < hanPriceOne, // price < $1
            "Treasury: hanPrice not eligible for bond purchase"
        );

        require(_hanAmount <= epochSupplyContractionLeft, "Treasury: not enough bond left to purchase");

        uint256 _rate = getBondDiscountRate();
        require(_rate > 0, "Treasury: invalid bond rate");

        uint256 _bondAmount = _hanAmount.mul(_rate).div(1e18);
        uint256 hanSupply = getTombCirculatingSupply();
        uint256 newBondSupply = IERC20(hbond).totalSupply().add(_bondAmount);
        require(newBondSupply <= hanSupply.mul(maxDebtRatioPercent).div(10000), "over max debt ratio");

        IBasisAsset(han).burnFrom(msg.sender, _hanAmount);
        IBasisAsset(hbond).mint(msg.sender, _bondAmount);

        epochSupplyContractionLeft = epochSupplyContractionLeft.sub(_hanAmount);
        _updateTombPrice();

        emit BoughtBonds(msg.sender, _hanAmount, _bondAmount);
    }

    function redeemBonds(uint256 _bondAmount, uint256 targetPrice) external onlyOneBlock checkCondition checkOperator {
        require(_bondAmount > 0, "Treasury: cannot redeem bonds with zero amount");

        uint256 hanPrice = getTombPrice();
        require(hanPrice == targetPrice, "Treasury: HANNIBAL price moved");
        require(
            hanPrice > hanPriceCeiling, // price > $1.01
            "Treasury: hanPrice not eligible for bond purchase"
        );

        uint256 _rate = getBondPremiumRate();
        require(_rate > 0, "Treasury: invalid bond rate");

        uint256 _hanAmount = _bondAmount.mul(_rate).div(1e18);
        require(IERC20(han).balanceOf(address(this)) >= _hanAmount, "Treasury: treasury has no more budget");

        seigniorageSaved = seigniorageSaved.sub(Math.min(seigniorageSaved, _hanAmount));

        IBasisAsset(hbond).burnFrom(msg.sender, _bondAmount);
        IERC20(han).safeTransfer(msg.sender, _hanAmount);

        _updateTombPrice();

        emit RedeemedBonds(msg.sender, _hanAmount, _bondAmount);
    }

    function _sendToMasonry(uint256 _amount) internal {
        IBasisAsset(han).mint(address(this), _amount);

        uint256 _daoFundSharedAmount = 0;
        if (daoFundSharedPercent > 0) {
            _daoFundSharedAmount = _amount.mul(daoFundSharedPercent).div(10000);
            IERC20(han).transfer(daoFund, _daoFundSharedAmount);
            emit DaoFundFunded(block.timestamp, _daoFundSharedAmount);
        }

        uint256 _devFundSharedAmount = 0;
        if (devFundSharedPercent > 0) {
            _devFundSharedAmount = _amount.mul(devFundSharedPercent).div(10000);
            IERC20(han).transfer(devFund, _devFundSharedAmount);
            emit DevFundFunded(block.timestamp, _devFundSharedAmount);
        }

        _amount = _amount.sub(_daoFundSharedAmount).sub(_devFundSharedAmount);

        IERC20(han).safeApprove(masonry, 0);
        IERC20(han).safeApprove(masonry, _amount);
        IMasonry(masonry).allocateSeigniorage(_amount);
        emit MasonryFunded(block.timestamp, _amount);
    }

    function _calculateMaxSupplyExpansionPercent(uint256 _hanSupply) internal returns (uint256) {
        for (uint8 tierId = 8; tierId >= 0; --tierId) {
            if (_hanSupply >= supplyTiers[tierId]) {
                maxSupplyExpansionPercent = maxExpansionTiers[tierId];
                break;
            }
        }
        return maxSupplyExpansionPercent;
    }

    function allocateSeigniorage() external onlyOneBlock checkCondition checkEpoch checkOperator {
        _updateTombPrice();
        previousEpochTombPrice = getTombPrice();
        uint256 hanSupply = getTombCirculatingSupply().sub(seigniorageSaved);
        if (epoch < bootstrapEpochs) {
            // 28 first epochs with 4.5% expansion
            _sendToMasonry(hanSupply.mul(bootstrapSupplyExpansionPercent).div(10000));
        } else {
            if (previousEpochTombPrice > hanPriceCeiling) {
                // Expansion ($HANNIBAL Price > 1 $FTM): there is some seigniorage to be allocated
                uint256 bondSupply = IERC20(hbond).totalSupply();
                uint256 _percentage = previousEpochTombPrice.sub(hanPriceOne);
                uint256 _savedForBond;
                uint256 _savedForMasonry;
                uint256 _mse = _calculateMaxSupplyExpansionPercent(hanSupply).mul(1e14);
                if (_percentage > _mse) {
                    _percentage = _mse;
                }
                if (seigniorageSaved >= bondSupply.mul(bondDepletionFloorPercent).div(10000)) {
                    // saved enough to pay debt, mint as usual rate
                    _savedForMasonry = hanSupply.mul(_percentage).div(1e18);
                } else {
                    // have not saved enough to pay debt, mint more
                    uint256 _seigniorage = hanSupply.mul(_percentage).div(1e18);
                    _savedForMasonry = _seigniorage.mul(seigniorageExpansionFloorPercent).div(10000);
                    _savedForBond = _seigniorage.sub(_savedForMasonry);
                    if (mintingFactorForPayingDebt > 0) {
                        _savedForBond = _savedForBond.mul(mintingFactorForPayingDebt).div(10000);
                    }
                }
                if (_savedForMasonry > 0) {
                    _sendToMasonry(_savedForMasonry);
                }
                if (_savedForBond > 0) {
                    seigniorageSaved = seigniorageSaved.add(_savedForBond);
                    IBasisAsset(han).mint(address(this), _savedForBond);
                    emit TreasuryFunded(block.timestamp, _savedForBond);
                }
            }
        }
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        // do not allow to drain core tokens
        require(address(_token) != address(han), "han");
        require(address(_token) != address(hbond), "bond");
        require(address(_token) != address(hashare), "share");
        _token.safeTransfer(_to, _amount);
    }

    function masonrySetOperator(address _operator) external onlyOperator {
        IMasonry(masonry).setOperator(_operator);
    }

    function masonrySetLockUp(uint256 _withdrawLockupEpochs, uint256 _rewardLockupEpochs) external onlyOperator {
        IMasonry(masonry).setLockUp(_withdrawLockupEpochs, _rewardLockupEpochs);
    }

    function masonryAllocateSeigniorage(uint256 amount) external onlyOperator {
        IMasonry(masonry).allocateSeigniorage(amount);
    }

    function masonryGovernanceRecoverUnsupported(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        IMasonry(masonry).governanceRecoverUnsupported(_token, _amount, _to);
    }
}
