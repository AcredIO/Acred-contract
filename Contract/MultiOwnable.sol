pragma solidity ^0.4.18;

import "./Ownable.sol";

contract MultiOwnable is Ownable {
    address[] public owners;
    
    event logGrantOwners(address indexed owner);
    event logRevokeOwners(address indexed owner);
    
    modifier onlyOwners {
        require(IsExistedOwner(msg.sender));
        _;
    }
    
    modifier onlyOwnersWithoutOwner {
        require(IsExistedOwner(msg.sender));
        require(msg.sender != owner);
        _;
    }
    
    function MultiOwnable() public {
        owners.length = MULTI_OWNER_COUNT;
        owners[0] = msg.sender;
    }
    
    function grantOwners(address _owner) onlyOwner public returns (bool success) {
        require(!IsExistedOwner(_owner));
        require(IsEmptyOwner());
        owners[getEmptyIndex()] = _owner;
        logGrantOwners(_owner);
        return true;
    }

    function revokeOwners(address _owner) onlyOwner public returns (bool success) {
        require(IsExistedOwner(_owner));
        owners[getOwnerIndex(_owner)] = address(0);
        logRevokeOwners(_owner);
        return true;
    }
    
    // helper
    function IsExistedOwner(address _owner) internal constant returns (bool) {
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
    
    function IsEmptyOwner() internal constant returns (bool) {
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