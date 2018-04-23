pragma solidity ^0.4.18;

import "./AcreConfig.sol";

contract Ownable is AcreConfig {
    address public owner;
    address public reservedOwner;
    uint public ownershipDeadline;
    
    event logReservedOwnership(address indexed oldOwner, address indexed newOwner);
    event logConfirmOwnership(address indexed oldOwner, address indexed newOwner);
    event logCancelOwnership(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier afterOwnershipDeadline { 
        require(now > ownershipDeadline); 
        _; 
    }

    function Ownable() public {
        owner = msg.sender;
    }
    
    function reservedOwnership(address newOwner) onlyOwner public returns (bool success) {
        require(newOwner != address(0));
        logReservedOwnership(owner, newOwner);
        reservedOwner = newOwner;
		ownershipDeadline = now + (OWNERSHIP_DURATION_TIME * TIME_FACTOR);
        return true;
    }
    
    function confirmOwnership() onlyOwner afterOwnershipDeadline public returns (bool success) {
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