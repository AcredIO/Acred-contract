pragma solidity 0.4.20;

import "./AcreConfig.sol";

contract Ownable is AcreConfig {
    address public owner;
    address public reservedOwner;
    uint public ownershipDeadline;
    
    event ReserveOwnership(address indexed oldOwner, address indexed newOwner);
    event ConfirmOwnership(address indexed oldOwner, address indexed newOwner);
    event CancelOwnership(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    function reserveOwnership(address newOwner) onlyOwner public returns (bool success) {
        require(newOwner != address(0));
        ReserveOwnership(owner, newOwner);
        reservedOwner = newOwner;
		ownershipDeadline = SafeMath.add(now, SafeMath.mul(OWNERSHIP_DURATION_TIME, TIME_FACTOR));
        return true;
    }
    
    function confirmOwnership() onlyOwner public returns (bool success) {
        require(reservedOwner != address(0));
        require(now > ownershipDeadline);
        ConfirmOwnership(owner, reservedOwner);
        owner = reservedOwner;
        reservedOwner = address(0);
        return true;
    }
    
    function cancelOwnership() onlyOwner public returns (bool success) {
        require(reservedOwner != address(0));
        CancelOwnership(owner, reservedOwner);
        reservedOwner = address(0);
        return true;
    }
}