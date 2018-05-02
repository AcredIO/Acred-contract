pragma solidity 0.4.20;

import "./MultiOwnable.sol";

contract Pausable is MultiOwnable {
    bool public paused = false;
    
    event logPause();
    event logUnpause();
    
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    
    modifier whenPaused() {
        require(paused);
        _;
    }
    
    modifier whenConditionalPassing() {
        if(!isManageable(msg.sender)) {
            require(!paused);
        }
        _;
    }
    
    function pause() onlyManagers whenNotPaused public returns (bool success) {
        paused = true;
        logPause();
        return true;
    }
  
    function unpause() onlyManagers whenPaused public returns (bool success) {
        paused = false;
        logUnpause();
        return true;
    }
}