pragma solidity ^0.4.18;

import "./ERC20.sol";
import "./Pausable.sol";

contract AcreToken is Pausable, TokenERC20 {
    string public version = '1.0';
    
    address public capital;
    
    mapping (uint16 => uint) public mineBalanceOf;
    mapping (address => bool) public frozenAccount;

    event logMintToken(address indexed mintedTarget, uint amount);
    event logFrozenAccount(address indexed target, bool frozen);
    event logMintMining(uint16 countryCode, uint preAmount, uint mineAmount, uint totalAmount);
    event logBurnMining(uint16 countryCode, uint value);
    event logMining(address indexed recipient, uint countryCode, uint value);
    
    function AcreToken(address _capital) TokenERC20(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, INIT_SUPPLY) public {
        capital = _capital;
        pause();
        mintToken(capital, CAPITAL_SUPPLY * 10 ** uint(decimals));
    }

    function _transfer(address _from, address _to, uint _value) bypassMultiOwner internal returns (bool success) {
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);
        return super._transfer(_from, _to, _value);
    }
    
    function mintToken(address _mintedTarget, uint _mintedAmount) onlyMultiOwner public returns (bool success) {
        balanceOf[_mintedTarget] = balanceOf[_mintedTarget].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        logMintToken(_mintedTarget, _mintedAmount);
        return true;
    }
    
    function burn(uint _value) onlyMultiOwner public returns (bool success) {
        return super.burn(_value);
    }
    
    function freezeAccount(address _target) onlyMultiOwner public returns (bool success) {
        require(!frozenAccount[_target]);
        frozenAccount[_target] = true;
        logFrozenAccount(_target, true);
        return true;
    }
    
    function unfreezeAccount(address _target) onlyMultiOwner public returns (bool success) {
        require(frozenAccount[_target]);
        frozenAccount[_target] = false;
        logFrozenAccount(_target, false);
        return true;
    }
    
    function withdrawalToken(uint _value) onlyMultiOwner public returns (bool success) {
        return _transfer(this, msg.sender, _value);
    }
    
    function getContractBalance() public constant returns (uint balance) {
        balance = balanceOf[this];
    }
    
    function mintMining(uint16 _countryCode, uint _mintedAmount) onlyMultiOwner public returns (bool success) {
        uint preMintedAmount = SafeMath.div(_mintedAmount, 100).mul(uint(PRE_MINTED_PERCENT));
        uint mineAmount = SafeMath.sub(_mintedAmount, preMintedAmount);
        mintToken(msg.sender, preMintedAmount);
        mineBalanceOf[_countryCode] = mineBalanceOf[_countryCode].add(mineAmount);
        logMintMining(_countryCode, preMintedAmount, mineAmount, _mintedAmount);
        return true;
    }
    
    function burnMining(uint16 _countryCode, uint _value) onlyMultiOwner public returns (bool success) {
        require(mineBalanceOf[_countryCode] >= _value);
        mineBalanceOf[_countryCode] = mineBalanceOf[_countryCode].sub(_value);
        logBurnMining(_countryCode, _value);
        return true;
    }
    
    function mining(address _recipient, uint16 _countryCode, uint _value) onlyMultiOwner public returns (bool success) {
        mintToken(_recipient, _value);
        burnMining(_countryCode, _value);
        logMining(_recipient, _countryCode, _value);
        return true;
    }
    
    function () public { revert(); }
}