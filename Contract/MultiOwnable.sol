pragma solidity ^0.4.18;

import "./Ownable.sol";

contract MultiOwnable is Ownable {
    address[] public owners;
    
    event logGrantOwners(address indexed owner);
    event logRevokeOwners(address indexed owner);
    
    modifier onlyOwners {
        require(isExistedOwner(msg.sender));
        _;
    }
    
    modifier onlyOwnersWithOwner {
        require(isExistedOwner(msg.sender) || msg.sender == owner);
        _;
    }
    
    modifier onlyOwnersWithoutOwner {
        require(isExistedOwner(msg.sender) && msg.sender != owner);
        _;
    }
    
    function MultiOwnable() public {
        owners.length = MULTI_OWNER_COUNT;
    }
    
    function grantOwners(address _owner) onlyOwner public returns (bool success) {
        require(!isExistedOwner(_owner));
        require(isEmptyOwner());
        owners[getEmptyIndex()] = _owner;
        logGrantOwners(_owner);
        return true;
    }

    function revokeOwners(address _owner) onlyOwner public returns (bool success) {
        require(isExistedOwner(_owner));
        owners[getOwnerIndex(_owner)] = address(0);
        logRevokeOwners(_owner);
        return true;
    }
    
    // helper
    function isExistedOwner(address _owner) internal constant returns (bool) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == _owner) {
                return true;
            }
        }
    }
    
    function getOwnerIndex(address _owner) internal constant returns (uint) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == _owner) {
                return i;
            }
        }
    }
    
    function isEmptyOwner() internal constant returns (bool) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == address(0)) {
                return true;
            }
        }
    }
    
    function getEmptyIndex() internal constant returns (uint) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == address(0)) {
                return i;
            }
        }
    }
}