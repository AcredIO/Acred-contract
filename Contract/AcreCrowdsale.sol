pragma solidity 0.4.20;

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
    
    function startCrowdsale() onlyManagers public {
        startSale(CROWDSALE_DURATION_TIME);
    }
    
    function getCurrentBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= SafeMath.add(startSaleTime, SafeMath.mul( 7, TIME_FACTOR))) { bonusRate = 20; } // 7days
        else if (now <= SafeMath.add(startSaleTime, SafeMath.mul(14, TIME_FACTOR))) { bonusRate = 15; } // 7days
        else if (now <= SafeMath.add(startSaleTime, SafeMath.mul(21, TIME_FACTOR))) { bonusRate = 10; } // 7days
        else                                                                        { bonusRate = 0; }  // 
    }
}
