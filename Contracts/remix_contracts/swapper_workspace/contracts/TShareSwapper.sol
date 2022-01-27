pragma solidity 0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./Operator.sol";

contract TShareSwapper is Operator {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public tomb;
    IERC20 public tbond;
    IERC20 public tshare;

    address public tombSpookyLpPair;
    address public tshareSpookyLpPair;

    address public wftmAddress;

    address public daoAddress;

    event TBondSwapPerformed(address indexed sender, uint256 tbondAmount, uint256 tshareAmount);


    constructor(
            address _tomb,
            address _tbond,
            address _tshare,
            address _wftmAddress,
            address _tombSpookyLpPair,
            address _tshareSpookyLpPair,
            address _daoAddress
    ) public {
        tomb = IERC20(_tomb);
        tbond = IERC20(_tbond);
        tshare = IERC20(_tshare);
        wftmAddress = _wftmAddress; 
        tombSpookyLpPair = _tombSpookyLpPair;
        tshareSpookyLpPair = _tshareSpookyLpPair;
        daoAddress = _daoAddress;
    }


    modifier isSwappable() {
        //TODO: What is a good number here?
        require(tomb.totalSupply() >= 60 ether, "ChipSwapMechanismV2.isSwappable(): Insufficient supply.");
        _;
    }

    function estimateAmountOfTShare(uint256 _tbondAmount) external view returns (uint256) {
        uint256 tshareAmountPerTomb = getTShareAmountPerTomb();
        return _tbondAmount.mul(tshareAmountPerTomb).div(1e18);
    }

    function swapTBondToTShare(uint256 _tbondAmount) external {
        require(getTBondBalance(msg.sender) >= _tbondAmount, "Not enough TBond in wallet");

        uint256 tshareAmountPerTomb = getTShareAmountPerTomb();
        uint256 tshareAmount = _tbondAmount.mul(tshareAmountPerTomb).div(1e18);
        require(getTShareBalance() >= tshareAmount, "Not enough TShare.");

        tbond.safeTransferFrom(msg.sender, daoAddress, _tbondAmount);
        tshare.safeTransfer(msg.sender, tshareAmount);

        emit TBondSwapPerformed(msg.sender, _tbondAmount, tshareAmount);
    }

    function withdrawTShare(uint256 _amount) external onlyOperator {
        require(getTShareBalance() >= _amount, "ChipSwapMechanism.withdrawFish(): Insufficient FISH balance.");
        tshare.safeTransfer(msg.sender, _amount);
    }

    function getTShareBalance() public view returns (uint256) {
        return tshare.balanceOf(address(this));
    }

    function getTBondBalance(address _user) public view returns (uint256) {
        return tbond.balanceOf(_user);
    }

    function getTombPrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(tombSpookyLpPair)
            .mul(1e18)
	    .div(tomb.balanceOf(tombSpookyLpPair));
    }

    function getTSharePrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(tshareSpookyLpPair)
            .mul(1e18)
            .div(tshare.balanceOf(tshareSpookyLpPair));
    }

    function getTShareAmountPerTomb() public view returns (uint256) {
        uint256 tombPrice = IERC20(wftmAddress).balanceOf(tombSpookyLpPair)
            .mul(1e18)
	    .div(tomb.balanceOf(tombSpookyLpPair));

        uint256 tsharePrice =
            IERC20(wftmAddress).balanceOf(tshareSpookyLpPair)
	    .mul(1e18)
            .div(tshare.balanceOf(tshareSpookyLpPair));
            

        return tombPrice.mul(1e18).div(tsharePrice);
    }

}
