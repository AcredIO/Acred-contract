pragma solidity 0.4.20;

import "./Pausable.sol";

contract Lockable is Pausable {
    mapping (address => uint) public locked;
    
    event Lockup(address indexed target, uint startTime, uint deadline);
    
    function lockup(address _target) onlyOwner public returns (bool success) {
	    require(!isManageable(_target));
        locked[_target] = SafeMath.add(now, SafeMath.mul(LOCKUP_DURATION_TIME, TIME_FACTOR));
        Lockup(_target, now, locked[_target]);
        return true;
    }
    
    // helper
    function isLockup(address _target) internal constant returns (bool) {
        if(now <= locked[_target])
            return true;
    }
}