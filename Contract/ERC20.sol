pragma solidity 0.4.20;

import "./SafeMath.sol";

interface tokenRecipient { 
    function receiveApproval(address _from, uint _value, address _token, bytes _extraData) external; 
}

contract TokenERC20 {
    using SafeMath for uint;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event logERC20Token(address indexed owner, string name, string symbol, uint8 decimals, uint supply);
    event logTransfer(address indexed from, address indexed to, uint value);
    event logTransferFrom(address indexed from, address indexed to, address indexed spender, uint value);
    event logApproval(address indexed owner, address indexed spender, uint value);
    
    function TokenERC20(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        uint _initialSupply
    ) public {
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _tokenDecimals;
        
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = totalSupply;
        
        logERC20Token(msg.sender, name, symbol, decimals, totalSupply);
    }

    function _transfer(address _from, address _to, uint _value) internal returns (bool success) {
        require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(SafeMath.add(balanceOf[_to], _value) > balanceOf[_to]);
        uint previousBalances = SafeMath.add(balanceOf[_from], balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        logTransfer(_from, _to, _value);
        assert(SafeMath.add(balanceOf[_from], balanceOf[_to]) == previousBalances);
        return true;
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        logTransferFrom(_from, _to, msg.sender, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        logApproval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}