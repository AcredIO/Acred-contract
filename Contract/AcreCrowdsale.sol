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
    
    function startCrowdsale() onlyOwnersWithMaster public {
        startSale(CROWDSALE_DURATION_TIME);
    }
    
    function getBonusRate() public constant returns(uint8 bonusRate) {
        if      (now <= startSaleTime + (8*TIME_FACTOR))  { bonusRate = 20; } // 6.11~6.18, 8days
        else if (now <= startSaleTime + (15*TIME_FACTOR)) { bonusRate = 15; } // 6.19~6.25, 7days
        else if (now <= startSaleTime + (22*TIME_FACTOR)) { bonusRate = 10; } // 6.26~7.2, 7days
        else                                              { bonusRate = 0; }  // 
    }
}
