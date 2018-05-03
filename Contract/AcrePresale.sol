pragma solidity 0.4.20;

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
    
    function startPresale() onlyManagers public {
        startSale(PRESALE_DURATION_TIME);
    }
    
    function getCurrentBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= SafeMath.add(startSaleTime, SafeMath.mul( 7, TIME_FACTOR))) { bonusRate = 30; } // 7days  
        else if (now <= SafeMath.add(startSaleTime, SafeMath.mul(15, TIME_FACTOR))) { bonusRate = 25; } // 8days
        else                                                                        { bonusRate = 0; }  // 
    } 
}