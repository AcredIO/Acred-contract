pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./Lockable.sol";

contract AcreToken is Lockable, TokenERC20 {
    string public version = '1.0';
    
    address public companyCapital;
    address public prePayment;
    
    uint public totalMineSupply;
    mapping (address => bool) public frozenAccount;

    event logFrozenAccount(address indexed target, bool frozen);
    event logBurn(address indexed owner, uint value);
    event logMining(address indexed recipient, uint value);
    
    function AcreToken(address _companyCapital, address _prePayment) TokenERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INIT_SUPPLY) public {
        companyCapital = _companyCapital;
        prePayment = _prePayment;
        transfer(companyCapital, CAPITAL_SUPPLY);
        transfer(prePayment, PRE_PAYMENT_SUPPLY);
        lockup(prePayment);
        pause(); 
    }

    function _transfer(address _from, address _to, uint _value) conditionalPaused internal returns (bool success) {
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);
        require(!isLockup(_from));
        require(!isLockup(_to));
        return super._transfer(_from, _to, _value);
    }
    
    function freezeAccount(address _target) onlyOwners public returns (bool success) {
        require(!frozenAccount[_target]);
        frozenAccount[_target] = true;
        logFrozenAccount(_target, true);
        return true;
    }
    
    function unfreezeAccount(address _target) onlyOwners public returns (bool success) {
        require(frozenAccount[_target]);
        frozenAccount[_target] = false;
        logFrozenAccount(_target, false);
        return true;
    }
    
    function withdrawalToken(uint _value) onlyOwners public returns (bool success) {
        return _transfer(this, msg.sender, _value);
    }
    
    function burn(uint _value) onlyOwners public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            
        totalSupply = totalSupply.sub(_value);                      
        logBurn(msg.sender, _value);
        return true;
    }
    
    function mining(address _recipient, uint _value) onlyOwners public returns (bool success) {
        require(_recipient != address(0));
        require(!isLockup(_recipient));
        require(totalMineSupply + _value <= MAX_MINING_SUPPLY);
        balanceOf[_recipient] = balanceOf[_recipient].add(_value);
        totalSupply = totalSupply.add(_value);
        totalMineSupply = totalMineSupply.add(_value);
        logMining(_recipient, _value);
        return true;
    }
    
    function getContractBalance() public constant returns (uint balance) {
        balance = balanceOf[this];
    }
    
    function () public { revert(); }
}