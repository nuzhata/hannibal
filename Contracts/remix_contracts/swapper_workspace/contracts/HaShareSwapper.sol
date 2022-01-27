pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./Operator.sol";

contract TShareSwapper is Operator {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public han;
    IERC20 public hbond;
    IERC20 public hashare;

    address public hanSpookyLpPair;
    address public hashareSpookyLpPair;

    address public wftmAddress;

    address public daoAddress;

    event TBondSwapPerformed(address indexed sender, uint256 hbondAmount, uint256 hashareAmount);


    constructor(
            address _han,
            address _hbond,
            address _hashare,
            address _wftmAddress,
            address _hanSpookyLpPair,
            address _hashareSpookyLpPair,
            address _daoAddress
    ) public {
        han = IERC20(_han);
        hbond = IERC20(_hbond);
        hashare = IERC20(_hashare);
        wftmAddress = _wftmAddress; 
        hanSpookyLpPair = _hanSpookyLpPair;
        hashareSpookyLpPair = _hashareSpookyLpPair;
        daoAddress = _daoAddress;
    }


    modifier isSwappable() {
        //TODO: What is a good number here?
        require(han.totalSupply() >= 60 ether, "ChipSwapMechanismV2.isSwappable(): Insufficient supply.");
        _;
    }

    function estimateAmountOfTShare(uint256 _hbondAmount) external view returns (uint256) {
        uint256 hashareAmountPerTomb = getTShareAmountPerTomb();
        return _hbondAmount.mul(hashareAmountPerTomb).div(1e18);
    }

    function swapTBondToTShare(uint256 _hbondAmount) external {
        require(getTBondBalance(msg.sender) >= _hbondAmount, "Not enough HBond in wallet");

        uint256 hashareAmountPerTomb = getTShareAmountPerTomb();
        uint256 hashareAmount = _hbondAmount.mul(hashareAmountPerTomb).div(1e18);
        require(getTShareBalance() >= hashareAmount, "Not enough HaShare.");

        hbond.safeTransferFrom(msg.sender, daoAddress, _hbondAmount);
        hashare.safeTransfer(msg.sender, hashareAmount);

        emit TBondSwapPerformed(msg.sender, _hbondAmount, hashareAmount);
    }

    function withdrawTShare(uint256 _amount) external onlyOperator {
        require(getTShareBalance() >= _amount, "ChipSwapMechanism.withdrawFish(): Insufficient FISH balance.");
        hashare.safeTransfer(msg.sender, _amount);
    }

    function getTShareBalance() public view returns (uint256) {
        return hashare.balanceOf(address(this));
    }

    function getTBondBalance(address _user) public view returns (uint256) {
        return hbond.balanceOf(_user);
    }

    function getTombPrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(hanSpookyLpPair)
            .mul(1e18)
	    .div(han.balanceOf(hanSpookyLpPair));
    }

    function getTSharePrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(hashareSpookyLpPair)
            .mul(1e18)
            .div(hashare.balanceOf(hashareSpookyLpPair));
    }

    function getTShareAmountPerTomb() public view returns (uint256) {
        uint256 hanPrice = IERC20(wftmAddress).balanceOf(hanSpookyLpPair)
            .mul(1e18)
	    .div(han.balanceOf(hanSpookyLpPair));

        uint256 hasharePrice =
            IERC20(wftmAddress).balanceOf(hashareSpookyLpPair)
	    .mul(1e18)
            .div(hashare.balanceOf(hashareSpookyLpPair));
            

        return hanPrice.mul(1e18).div(hasharePrice);
    }

} 
