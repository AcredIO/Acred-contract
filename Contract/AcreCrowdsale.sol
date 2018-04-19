pragma solidity ^0.4.18;

import "./AcreSale.sol";

contract AcreCrowdsale is AcreSale {
    function AcreCrowdsale(
        address _sendEther,
        uint _softCapToken,
        uint _hardCapToken,
        AcreToken _addressOfTokenUsedAsReward
    ) AcreSale(
        _sendEther,
        _softCapToken, 
        _hardCapToken, 
        _addressOfTokenUsedAsReward) public {
    }
    
    function getBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= startTime + (6*TIME_FACTOR))  { bonusRate = 30; } // 6.4~6.9, 1~6 days
        else if (now <= startTime + (12*TIME_FACTOR)) { bonusRate = 25; } // 6.10~6.15, 7~12 days
        else if (now <= startTime + (18*TIME_FACTOR)) { bonusRate = 20; } // 6.16~6.21, 13~18 days
        else if (now <= startTime + (24*TIME_FACTOR)) { bonusRate = 15; } // 6.22~6.27, 19~24 days    
        else if (now <= startTime + (30*TIME_FACTOR)) { bonusRate = 10; } // 6.28~7.3, 25~30 days    
        else                                          { bonusRate = 0; }  // later
    }
}