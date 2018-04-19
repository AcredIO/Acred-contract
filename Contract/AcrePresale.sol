pragma solidity ^0.4.18;

import "./AcreSale.sol";

contract AcrePresale is AcreSale {
    function AcrePresale(
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
        if      (now <= startTime + (8*TIME_FACTOR))  { bonusRate = 50; } // 4.23~4.30, 1~8 days  
        else if (now <= startTime + (19*TIME_FACTOR)) { bonusRate = 40; } // 5.1~5.11, 9~19 days
        else                                          { bonusRate = 0; }  // later
    } 
}