pragma solidity ^0.4.18;

import "./Pausable.sol";

contract Lockable is Pausable {
    mapping (address => uint) public locked;
    
    event logLockup(address indexed target, uint startTime, uint deadline);
    
    modifier afterLockedDeadline {
        require(now > locked[msg.sender]);
        _;
    }

    function lockup(address _target) onlyOwner afterLockedDeadline public returns (bool success) {
	    require(!isExistedOwner(_target) && owner != _target);
        locked[_target] = now + (LOCKUP_DURATION_TIME * TIME_FACTOR);
        logLockup(_target, now, locked[_target]);
        return true;
    }
    
    function isLockup(address _target) internal constant returns (bool) {
        if(now <= locked[_target])
            return true;
    }
}