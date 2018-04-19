pragma solidity ^0.4.18;

import "./Ownable.sol";

contract MultiOwnable is Ownable {
    mapping(uint=>address) public owners;
    
    event logGrantMultiOwner(address indexed owner);
    event logRevokeMultiOwner(address indexed owner);
    
    modifier onlyMultiOwner {
        require(IsExistedOwner(msg.sender));
        _;
    }
    
    function MultiOwnable() public {
        owners[0] = msg.sender;
    }
    
    function grantMultiOwner(address _owner) onlyOwner public returns (bool success) {
        require(!IsExistedOwner(_owner));
        require(IsBlankOwner());
        owners[getBlankIndex()] = _owner;
        logGrantMultiOwner(_owner);
        return true;
    }

    function revokeMultiOwner(address _owner) onlyOwner public returns (bool success) {
        require(IsExistedOwner(_owner));
        owners[getOwnerIndex(_owner)] = address(0);
        logRevokeMultiOwner(_owner);
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
    
    function IsBlankOwner() internal constant returns (bool) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == address(0)) {
                return true;
            }
        }
    }
    
    function getBlankIndex() internal constant returns (uint) {
        for(uint8 i = 0; i < MULTI_OWNER_COUNT; ++i) {
            if(owners[i] == address(0)) {
                return i;
            }
        }
    }
}