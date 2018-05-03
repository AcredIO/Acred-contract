pragma solidity 0.4.20;

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
    event logWithdrawContractToken(address indexed owner, uint value);
    
    function AcreToken(address _companyCapital, address _prePayment) TokenERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INITIAL_SUPPLY) public {
        require(_companyCapital != address(0));
        require(_prePayment != address(0));
        companyCapital = _companyCapital;
        prePayment = _prePayment;
        transfer(companyCapital, CAPITAL_SUPPLY);
        transfer(prePayment, PRE_PAYMENT_SUPPLY);
        lockup(prePayment);
        pause(); 
    }

    function _transfer(address _from, address _to, uint _value) whenConditionalPassing internal returns (bool success) {
        require(!frozenAccount[_from]); // freeze                     
        require(!frozenAccount[_to]);
        require(!isLockup(_from));      // lockup
        require(!isLockup(_to));
        return super._transfer(_from, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(!frozenAccount[msg.sender]); // freeze
        require(!isLockup(msg.sender));      // lockup
        return super.transferFrom(_from, _to, _value);
    }
    
    function freezeAccount(address _target) onlyManagers public returns (bool success) {
        require(!isManageable(_target));
        require(!frozenAccount[_target]);
        frozenAccount[_target] = true;
        logFrozenAccount(_target, true);
        return true;
    }
    
    function unfreezeAccount(address _target) onlyManagers public returns (bool success) {
        require(frozenAccount[_target]);
        frozenAccount[_target] = false;
        logFrozenAccount(_target, false);
        return true;
    }
    
    function burn(uint _value) onlyManagers public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            
        totalSupply = totalSupply.sub(_value);                      
        logBurn(msg.sender, _value);
        return true;
    }
    
    function mining(address _recipient, uint _value) onlyManagers public returns (bool success) {
        require(_recipient != address(0));
        require(!frozenAccount[_recipient]); // freeze
        require(!isLockup(_recipient));      // lockup
        require(SafeMath.add(totalMineSupply, _value) <= MAX_MINING_SUPPLY);
        balanceOf[_recipient] = balanceOf[_recipient].add(_value);
        totalSupply = totalSupply.add(_value);
        totalMineSupply = totalMineSupply.add(_value);
        logMining(_recipient, _value);
        return true;
    }
    
    function withdrawContractToken(uint _value) onlyManagers public returns (bool success) {
        _transfer(this, msg.sender, _value);
        logWithdrawContractToken(msg.sender, _value);
        return true;
    }
    
    function getContractBalanceOf() public constant returns(uint blance) {
        blance = balanceOf[this];
    }
    
    function getRemainingMineSupply() public constant returns(uint supply) {
        supply = MAX_MINING_SUPPLY - totalMineSupply;
    }
    
    function () public { revert(); }
}