pragma solidity ^0.4.18;

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
    
    modifier conditionalPaused() {
        if(!isExistedOwner(msg.sender)) {
            require(!paused);
        }
        _;
    }
    
    function pause() onlyOwners whenNotPaused public returns (bool success) {
        paused = true;
        logPause();
        return true;
    }
  
    function unpause() onlyOwners whenPaused public returns (bool success) {
        paused = false;
        logUnpause();
        return true;
    }
}