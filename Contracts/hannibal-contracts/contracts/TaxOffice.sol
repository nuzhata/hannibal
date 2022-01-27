// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

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
contract TaxOffice is Operator {
    address public han;

    constructor(address _han) public {
        require(_han != address(0), "han address cannot be 0");
        han = _han;
    }

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(han).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(han).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(han).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(han).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(han).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(han).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(han).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(han).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(han).includeAddress(_address);
    }

    function setTaxableHanOracle(address _hanOracle) external onlyOperator {
        ITaxable(han).setHanOracle(_hanOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(han).setTaxOffice(_newTaxOffice);
    }
}
