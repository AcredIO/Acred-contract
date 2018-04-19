pragma solidity ^0.4.18;

import "./AcreTokenConfig.sol";

contract Ownable is AcreTokenConfig {
    address public owner;
    address public reservedOwner;
    uint public startTime;
    
    event logTransferOwnership(address indexed oldOwner, address indexed newOwner);
    event logConfirmOwnership(address indexed oldOwner, address indexed newOwner);
    event logCancelOwnership(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier confirmDeadline { 
        require(now >= (startTime + (OWNERSHIP_DURATION_TIME * TIME_FACTOR))); 
        _; 
    }

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner public returns (bool success) {
        require(newOwner != address(0));
        logTransferOwnership(owner, newOwner);
        reservedOwner = newOwner;
        startTime = now;
        return true;
    }
    
    function confirmOwnership() onlyOwner confirmDeadline public returns (bool success) {
        require(reservedOwner != address(0));
        logConfirmOwnership(owner, reservedOwner);
        owner = reservedOwner;
        reservedOwner = address(0);
        return true;
    }
    
    function cancelOwnership() onlyOwner public returns (bool success) {
        require(reservedOwner != address(0));
        logCancelOwnership(owner, reservedOwner);
        reservedOwner = address(0);
        return true;
    }
}