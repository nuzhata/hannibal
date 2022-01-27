// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
contract HanTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public han;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _han,
        address _wftm,
        address _pair
    ) public {
        require(_han != address(0), "han address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        han = IERC20(_han);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(han), "token needs to be han");
        uint256 hanBalance = han.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(hanBalance.div(wftmBalance));
    }

    function setHan(address _han) external onlyOwner {
        require(_han != address(0), "han address cannot be 0");
        han = IERC20(_han);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }



}
